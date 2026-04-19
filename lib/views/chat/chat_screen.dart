import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentora_app/controllers/chat_controller.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/models/message_model.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/models/store_model.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class ChatScreen extends StatefulWidget {
  final String threadId;
  final UserModel otherUser;
  final StoreModel? otherStore;

  const ChatScreen({
    super.key,
    required this.threadId,
    required this.otherUser,
    this.otherStore,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _chatController = ChatController();
  final UserController _userController = UserController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  UserModel? _currentUser;
  bool _scrolledToBottomOnOpen = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = await _userController.getCurrentUser();
    if (!mounted) return;
    setState(() => _currentUser = u);
    await _chatController.markThreadRead(widget.threadId);
  }

  void _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _chatController.sendMessage(widget.threadId, text);
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    try {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          pos,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(pos);
      }
    } catch (_) {}
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dateHeaderText(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDate).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    final day = msgDate.day.toString().padLeft(2, '0');
    final month = msgDate.month.toString().padLeft(2, '0');
    final year = msgDate.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final sName = widget.otherStore?.name ?? '';
    final uName = widget.otherUser.username ?? '';
    final eMail = widget.otherUser.email;
    final displayName = sName.isNotEmpty
        ? sName
        : (uName.isNotEmpty ? uName : (eMail.isNotEmpty ? eMail : 'Pengguna'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  (widget.otherStore?.image ?? widget.otherUser.image) !=
                          null &&
                      (widget.otherStore?.image ?? widget.otherUser.image)!
                          .isNotEmpty
                  ? NetworkImage(
                          (widget.otherStore?.image ?? widget.otherUser.image)!,
                        )
                        as ImageProvider
                  : null,
              backgroundColor: AppColor.primarySoft,
              child:
                  (widget.otherStore?.image ?? widget.otherUser.image ?? '')
                      .isEmpty
                  ? Icon(
                      widget.otherStore != null ? Icons.store : Icons.person,
                      color: AppColor.primary,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatController.streamMessages(widget.threadId),
              builder: (context, snapshot) {
                if (_currentUser == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Terjadi kesalahan saat memuat pesan:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final messages = docs
                    .map(
                      (d) => MessageModel.fromMap(
                        d.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();
                if (!_scrolledToBottomOnOpen && messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animate: false);
                  });
                  _scrolledToBottomOnOpen = true;
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderUid == _currentUser?.uid;

                    final msgDate = DateTime(
                      m.createdAt.year,
                      m.createdAt.month,
                      m.createdAt.day,
                    );
                    var showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prev = messages[index - 1];
                      final prevDate = DateTime(
                        prev.createdAt.year,
                        prev.createdAt.month,
                        prev.createdAt.day,
                      );
                      if (prevDate != msgDate) showDateHeader = true;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColor.shadowLight,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                _dateHeaderText(m.createdAt.toLocal()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? AppColor.primary : AppColor.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColor.shadowLight,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.text,
                                  textAlign: isMe
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: TextStyle(
                                    color: isMe
                                        ? AppColor.textOnPrimary
                                        : AppColor.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatTime(m.createdAt.toLocal()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? AppColor.textOnPrimary.withOpacity(
                                            0.8,
                                          )
                                        : AppColor.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColor.border)),
              color: AppColor.backgroundLight,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Ketik pesan...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  color: AppColor.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
