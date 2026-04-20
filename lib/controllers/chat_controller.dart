import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/services/database/chat_service.dart';

class ChatController {
  final UserController _userController = UserController();
  final ChatService _chatService = ChatService();

  Future<Stream<QuerySnapshot>> streamThreadsForCurrentUser() async {
    // Ambil user yang sedang login
    final user = await _userController.getCurrentUser();
    if (user == null) {
      // Jika belum login, kembalikan stream kosong
      return Stream<QuerySnapshot>.empty();
    }
    // Jika sudah login, kembalikan stream thread chat user
    return _chatService.streamThreadsForUser(user.uid);
  }

  Future<String> createOrGetThreadWith(String otherUid) async {
    // Ambil user yang sedang login
    final user = await _userController.getCurrentUser();
    if (user == null) {
      throw Exception('User belum login');
    }
    // Buat thread baru atau ambil thread yang sudah ada
    return await _chatService.getOrCreateThread(user.uid, otherUid);
  }

  Stream<QuerySnapshot> streamMessages(String threadId) {
    // Stream pesan pada thread tertentu
    return _chatService.streamMessages(threadId);
  }

  Future<void> sendMessage(String threadId, String text) async {
    // Ambil user yang sedang login
    final user = await _userController.getCurrentUser();
    if (user == null) {
      throw Exception('User belum login');
    }
    // Kirim pesan ke thread
    await _chatService.sendMessage(
      threadId: threadId,
      senderUid: user.uid,
      text: text,
    );
  }

  Future<void> markThreadRead(String threadId) async {
    // Tandai thread sudah dibaca oleh user
    final user = await _userController.getCurrentUser();
    if (user == null) {
      return;
    }
    await _chatService.markThreadRead(threadId, user.uid);
  }

  Future<int> getUnreadCount(String threadId) async {
    // Ambil jumlah pesan belum dibaca di thread
    final user = await _userController.getCurrentUser();
    if (user == null) {
      return 0;
    }
    return await _chatService.getUnreadCount(threadId, user.uid);
  }
}
