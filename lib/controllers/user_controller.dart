import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/firebase_service.dart';
import 'package:rentora_app/services/database/user_service.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class UserController {
  Future<UserModel?> getUserByUid(String uid) async {
    // Ambil user berdasarkan uid
    return await UserFirestoreService.getUserByUid(uid);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login({required String email, required String password}) async {
    // Login user dengan email dan password
    _isLoading = true;
    try {
      final cred = await FirebaseService.loginUser(
        email: email,
        password: password,
      );
      if (cred != null) {
        // Jika login berhasil, simpan status login dan email
        PreferenceHandler().storingIsLogin(true);
        PreferenceHandler().storingUserEmail(email);
        _isLoading = false;
        return true;
      } else {
        // Jika login gagal
        _isLoading = false;
        return false;
      }
    } catch (_) {
      // Jika terjadi error
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
    // Register user baru
    await FirebaseService.registerUser(
      email: email,
      password: password,
      phone: phone,
      username: username ?? '',
    );
    // Setelah register, simpan status login dan email
    PreferenceHandler().storingIsLogin(true);
    PreferenceHandler().storingUserEmail(email);
  }

  Future<UserModel?> getCurrentUser() async {
    // Ambil user yang sedang login dari local storage
    final email = await PreferenceHandler.getUserEmail();
    if (email == null) {
      return null;
    }
    return await UserFirestoreService.getUserByEmail(email);
  }

  Future<void> updateCurrentUser({
    String? username,
    String? phone,
    String? image,
  }) async {
    // Update data user yang sedang login
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
