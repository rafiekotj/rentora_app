import 'package:cloud_firestore/cloud_firestore.dart';

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
  }

  Future<void> markThreadRead(String threadId, String userUid) async {
    final snapshot = await chatsCollection
        .doc(threadId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();

    final toUpdate = snapshot.docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final sender = data['sender_uid'] as String? ?? '';
      return sender != userUid;
    }).toList();

    if (toUpdate.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final d in toUpdate) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }
}
