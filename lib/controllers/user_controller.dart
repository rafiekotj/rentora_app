import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/firebase_service.dart';
import 'package:rentora_app/services/database/user_service.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class UserController {
  // Ambil user by uid (untuk seller melihat peminjam)
  Future<UserModel?> getUserByUid(String uid) async {
    return await UserFirestoreService.getUserByUid(uid);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    try {
      final cred = await FirebaseService.loginUser(
        email: email,
        password: password,
      );
      if (cred != null) {
        PreferenceHandler().storingIsLogin(true);
        PreferenceHandler().storingUserEmail(email);
        _isLoading = false;
        return true;
      } else {
        _isLoading = false;
        return false;
      }
    } catch (_) {
      _isLoading = false;
      return false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? username,
    String? image,
  }) async {
    await FirebaseService.registerUser(
      email: email,
      password: password,
      phone: phone,
      username: username ?? '',
    );
    PreferenceHandler().storingIsLogin(true);
    PreferenceHandler().storingUserEmail(email);
  }

  // Mengambil detail data user yang sedang login
  Future<UserModel?> getCurrentUser() async {
    final email = await PreferenceHandler.getUserEmail();
    if (email == null) return null;
    return await UserFirestoreService.getUserByEmail(email);
  }

  /// Update the currently logged in user's profile information.
  Future<void> updateCurrentUser({
    String? username,
    String? phone,
    String? image,
  }) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User belum login');
    }
    await UserFirestoreService.updateUser(
      uid: user.uid,
      username: username ?? user.username,
      phone: phone ?? user.phone,
      image: image ?? user.image,
    );
  }
}
