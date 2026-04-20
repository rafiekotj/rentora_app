import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentora_app/controllers/chat_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/services/database/user_service.dart';
import 'package:rentora_app/services/database/store_service.dart';
import 'package:rentora_app/views/chat/chat_screen.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController _chatController = ChatController();
  final UserController _userController = UserController();
  final StoreService _storeService = StoreService();

  Stream<QuerySnapshot>? _threadsStream;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = await _userController.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
    if (user != null) {
      final s = await _chatController.streamThreadsForCurrentUser();
      if (!mounted) return;
      setState(() => _threadsStream = s);
    }
  }

  Future<Map<String, dynamic>?> _resolveOther(String otherUid) async {
    try {
      final store = await _storeService.getStoreByUserId(otherUid);
      if (store != null) return {'type': 'store', 'store': store};
      final user = await UserFirestoreService.getUserByUid(otherUid);
      if (user != null) return {'type': 'user', 'user': user};
    } catch (_) {}
    return null;
  }

  DateTime? _parseTimestamp(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value).toLocal();
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      }
      if (value is Map) {
        final seconds = value['seconds'] ?? value['_seconds'];
        if (seconds is int) {
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toLocal();
        }
      }
    } catch (_) {}
    return null;
  }

  String _formatThreadTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(local.year, local.month, local.day);
    final diff = today.difference(msgDate).inDays;
    if (diff == 0) {
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
      ),
      body: _threadsStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _threadsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final err = snapshot.error;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Terjadi error saat memuat percakapan:\n${err.toString()}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada percakapan'));
                }

                final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                sortedDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aLu = aData['last_updated'];
                  final bLu = bData['last_updated'];

                  DateTime da = DateTime.fromMillisecondsSinceEpoch(0);
                  DateTime db = DateTime.fromMillisecondsSinceEpoch(0);
                  try {
                    if (aLu is Timestamp) {
                      da = aLu.toDate();
                    } else if (aLu is String) {
                      da = DateTime.parse(aLu);
                    }
                  } catch (_) {}
                  try {
                    if (bLu is Timestamp) {
                      db = bLu.toDate();
                    } else if (bLu is String) {
                      db = DateTime.parse(bLu);
                    }
                  } catch (_) {}

                  return db.compareTo(da);
                });

                return ListView.separated(
                  itemCount: sortedDocs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = sortedDocs[index];
                    final data = d.data() as Map<String, dynamic>;
                    final participants = List<String>.from(
                      data['participants'] ?? <String>[],
                    );
                    final threadId = d.id;
                    final otherUid = participants.firstWhere(
                      (p) => p != _currentUser?.uid,
                      orElse: () => '',
                    );

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: otherUid.isNotEmpty
                          ? _resolveOther(otherUid)
                          : Future.value(null),
                      builder: (context, otherSnapshot) {
                        final result = otherSnapshot.data;
                        final StoreModel? store =
                            result != null && result['type'] == 'store'
                            ? result['store'] as StoreModel
                            : null;
                        final UserModel? other =
                            result != null && result['type'] == 'user'
                            ? result['user'] as UserModel
                            : null;
                        final lastMessage = data['last_message'] ?? '';

                        DateTime? lastUpdated = _parseTimestamp(
                          data['last_updated'],
                        );

                        int unreadCount = 0;
                        final unreadRaw =
                            data['unread'] ??
                            data['unread_count'] ??
                            data['unreadCounts'] ??
                            data['unread_counts'];
                        try {
                          if (unreadRaw is int) {
                            unreadCount = unreadRaw;
                          } else if (unreadRaw is String) {
                            unreadCount = int.tryParse(unreadRaw) ?? 0;
                          } else if (unreadRaw is Map &&
                              _currentUser?.uid != null) {
                            final u =
                                unreadRaw[_currentUser!.uid] ??
                                unreadRaw[_currentUser!.uid.toString()];
                            if (u is int) {
                              unreadCount = u;
                            } else if (u is String) {
                              unreadCount = int.tryParse(u) ?? 0;
                            }
                          }
                        } catch (_) {}

                        final sName = store?.name ?? '';
                        final uName = other?.username ?? '';
                        final eMail = other?.email ?? '';
                        final displayName = sName.isNotEmpty
                            ? sName
                            : (uName.isNotEmpty
                                  ? uName
                                  : (eMail.isNotEmpty ? eMail : 'Pengguna'));

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final targetUser =
                                  other ??
                                  UserModel(
                                    uid: otherUid,
                                    email:
                                        otherUid, // fallback ke UID jika email tidak ada
                                    phone: '',
                                    username: null,
                                    image: null,
                                  );
                              await context.push(
                                ChatScreen(
                                  threadId: threadId,
                                  otherUser: targetUser,
                                  otherStore: store,
                                ),
                              );
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage:
                                        (store?.image ?? other?.image) !=
                                                null &&
                                            (store?.image ?? other?.image)!
                                                .isNotEmpty
                                        ? NetworkImage(
                                                (store?.image ?? other?.image)!,
                                              )
                                              as ImageProvider
                                        : null,
                                    backgroundColor: AppColor.primarySoft,
                                    child:
                                        (store?.image ?? other?.image ?? '')
                                            .isEmpty
                                        ? Icon(
                                            store != null
                                                ? Icons.store
                                                : Icons.person,
                                            color: AppColor.primary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                displayName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatThreadTime(lastUpdated),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColor.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                lastMessage,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: AppColor.textSecondary,
                                                ),
                                              ),
                                            ),
                                            FutureBuilder<int>(
                                              future: _chatController
                                                  .getUnreadCount(threadId),
                                              builder: (context, ucSnap) {
                                                final dynamicUnread =
                                                    ucSnap.data ?? 0;
                                                final effectiveUnread =
                                                    dynamicUnread > 0
                                                    ? dynamicUnread
                                                    : unreadCount;
                                                if (effectiveUnread <= 0) {
                                                  return const SizedBox();
                                                }
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 8,
                                                      ),
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: AppColor.primary,
                                                      shape: BoxShape.circle,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: AppColor
                                                              .shadowLight,
                                                          blurRadius: 2,
                                                          offset: Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      effectiveUnread > 99
                                                          ? '99+'
                                                          : effectiveUnread
                                                                .toString(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppColor
                                                            .textOnPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
