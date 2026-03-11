import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class UserController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;

    final UserModel? login = await DBHelper.loginUser(
      email: email,
      password: password,
    );

    if (login != null) {
      PreferenceHandler().storingIsLogin(true);
      PreferenceHandler().storingUserEmail(login.email);
      _isLoading = false;
      return true;
    } else {
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
    await DBHelper.registerUser(
      UserModel(
        email: email,
        password: password,
        phone: phone,
        username: username,
        image: image,
      ),
    );

    PreferenceHandler().storingIsLogin(true);
    PreferenceHandler().storingUserEmail(email);
  }

  // Mengambil email user yang tersimpan di local
  Future<String?> getUserEmail() async {
    return await PreferenceHandler.getUserEmail();
  }

  // Mengambil detail data user yang sedang login
  Future<UserModel?> getCurrentUser() async {
    final email = await PreferenceHandler.getUserEmail();

    if (email == null) return null;

    final db = await DBHelper.database();

    final result = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }

    return null;
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

    final updated = UserModel(
      id: user.id,
      email: user.email,
      password: user.password,
      phone: phone ?? user.phone,
      username: username ?? user.username,
      image: image ?? user.image,
    );

    await DBHelper.updateUser(updated);
  }
}
