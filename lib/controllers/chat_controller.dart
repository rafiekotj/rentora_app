import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/services/database/chat_service.dart';

class ChatController {
  final UserController _userController = UserController();
  final ChatService _chatService = ChatService();

  Future<Stream<QuerySnapshot>> streamThreadsForCurrentUser() async {
    final user = await _userController.getCurrentUser();
    if (user == null) return Stream<QuerySnapshot>.empty();
    return _chatService.streamThreadsForUser(user.uid);
  }

  Future<String> createOrGetThreadWith(String otherUid) async {
    final user = await _userController.getCurrentUser();
    if (user == null) throw Exception('User belum login');
    return await _chatService.getOrCreateThread(user.uid, otherUid);
  }

  Stream<QuerySnapshot> streamMessages(String threadId) {
    return _chatService.streamMessages(threadId);
  }

  Future<void> sendMessage(String threadId, String text) async {
    final user = await _userController.getCurrentUser();
    if (user == null) throw Exception('User belum login');
    await _chatService.sendMessage(
      threadId: threadId,
      senderUid: user.uid,
      text: text,
    );
  }

  Future<void> markThreadRead(String threadId) async {
    final user = await _userController.getCurrentUser();
    if (user == null) return;
    await _chatService.markThreadRead(threadId, user.uid);
  }

  Future<int> getUnreadCount(String threadId) async {
    final user = await _userController.getCurrentUser();
    if (user == null) return 0;
    return await _chatService.getUnreadCount(threadId, user.uid);
  }
}
