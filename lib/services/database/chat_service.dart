import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rentora_app/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:rentora_app/config/onesignal_secrets.dart';
import 'package:rentora_app/services/database/user_service.dart';

class ChatService {
  final CollectionReference chatsCollection = FirebaseFirestore.instance
      .collection('chats');

  static String threadIdFor(String a, String b) {
    return a.compareTo(b) <= 0 ? '${a}_${b}' : '${b}_${a}';
  }

  Future<String> getOrCreateThread(String userA, String userB) async {
    final id = threadIdFor(userA, userB);
    final docRef = chatsCollection.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': id,
        'participants': [userA, userB],
        'last_message': '',
        'last_updated': FieldValue.serverTimestamp(),
      });
    }
    return id;
  }

  Stream<QuerySnapshot> streamThreadsForUser(String uid) {
    return chatsCollection
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> streamMessages(String threadId) {
    return chatsCollection
        .doc(threadId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderUid,
    required String text,
  }) async {
    final msgRef = chatsCollection.doc(threadId).collection('messages').doc();
    final data = {
      'uid': msgRef.id,
      'sender_uid': senderUid,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
      'read': false,
    };
    await msgRef.set(data);
    await chatsCollection.doc(threadId).update({
      'last_message': text,
      'last_message_sender': senderUid,
      'last_updated': FieldValue.serverTimestamp(),
    });

    // Send OneSignal notification to other participants (client-side push).
    // If server-side notifications are enabled, Cloud Functions or server should handle notifications.
    if (!AppConfig.useServerSideNotifications) {
      Future.microtask(() async {
        try {
          final threadDoc = await chatsCollection.doc(threadId).get();
          if (!threadDoc.exists) return;
          final threadData = threadDoc.data() as Map<String, dynamic>;
          final participants = List<String>.from(
            threadData['participants'] ?? <String>[],
          );
          final targets = participants.where((p) => p != senderUid).toList();
          if (targets.isEmpty) return;

          String subtitle = '';
          try {
            final senderUser = await UserFirestoreService.getUserByUid(
              senderUid,
            );
            if (senderUser != null) {
              subtitle = (senderUser.username ?? senderUser.email);
            }
          } catch (_) {}

          final payload = {
            'app_id': AppConfig.appIdOneSignal,
            'include_external_user_ids': targets,
            'headings': {'en': 'Pesan Baru'},
            'subtitle': {'en': subtitle},
            'contents': {
              'en': text.isNotEmpty ? text : 'Anda menerima pesan baru.',
            },
            'data': {'threadId': threadId, 'senderUid': senderUid},
          };

          final uri = Uri.parse('https://onesignal.com/api/v1/notifications');
          try {
            final resp = await http
                .post(
                  uri,
                  headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'Authorization':
                        'Basic ${OneSignalSecrets.onesignalRestApiKey}',
                  },
                  body: jsonEncode(payload),
                )
                .timeout(const Duration(seconds: 6));

            if (kDebugMode) {
              debugPrint(
                '[OneSignal] sendMessage status=${resp.statusCode} body=${resp.body}',
              );
            }

            if (resp.statusCode != 200 && resp.statusCode != 201) {
              // retry once after short delay if no recipients or not subscribed
              await Future.delayed(const Duration(milliseconds: 900));
              final resp2 = await http
                  .post(
                    uri,
                    headers: {
                      'Content-Type': 'application/json; charset=utf-8',
                      'Authorization':
                          'Basic ${OneSignalSecrets.onesignalRestApiKey}',
                    },
                    body: jsonEncode(payload),
                  )
                  .timeout(const Duration(seconds: 6));
              if (kDebugMode) {
                debugPrint(
                  '[OneSignal] retry status=${resp2.statusCode} body=${resp2.body}',
                );
              }
            }
          } catch (e, st) {
            if (kDebugMode) debugPrint('[OneSignal] send error: $e\n$st');
          }
        } catch (_) {}
      });
    }
  }

  Future<void> markThreadRead(String threadId, String userUid) async {
    final msgsRef = chatsCollection.doc(threadId).collection('messages');
    final snapshot = await msgsRef.where('read', isEqualTo: false).get();

    final toUpdate = snapshot.docs.where((d) {
      final data = d.data();
      final sender = data['sender_uid'] as String? ?? '';
      return sender != userUid;
    }).toList();

    final batch = FirebaseFirestore.instance.batch();

    for (final d in toUpdate) {
      batch.update(d.reference, {'read': true});
    }

    // Also update thread-level unread maps so UI badges relying on doc fields clear.
    final threadRef = chatsCollection.doc(threadId);
    final updates = <String, dynamic>{};
    updates['unread.$userUid'] = 0;
    updates['unread_counts.$userUid'] = 0;
    updates['unreadCounts.$userUid'] = 0;
    batch.update(threadRef, updates);

    await batch.commit();
  }

  Future<int> getUnreadCount(String threadId, String currentUid) async {
    try {
      final snapshot = await chatsCollection
          .doc(threadId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .get();
      int cnt = 0;
      for (final d in snapshot.docs) {
        final data = d.data();
        final sender = data['sender_uid'] as String? ?? '';
        if (sender != currentUid) cnt++;
      }
      return cnt;
    } catch (_) {
      return 0;
    }
  }

  Stream<int> streamUnreadThreadsCountForUser(String uid) {
    return chatsCollection
        .where('participants', arrayContains: uid)
        .snapshots()
        .asyncMap((query) async {
          try {
            final futures = query.docs.map((d) async {
              try {
                final msgs = await chatsCollection
                    .doc(d.id)
                    .collection('messages')
                    .where('read', isEqualTo: false)
                    .get();
                for (final m in msgs.docs) {
                  final data = m.data();
                  final sender = data['sender_uid'] as String? ?? '';
                  if (sender != uid) return 1;
                }
              } catch (_) {}
              return 0;
            }).toList();

            final results = await Future.wait(futures);
            return results.where((r) => r == 1).length;
          } catch (_) {
            return 0;
          }
        });
  }
}
