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

  Future<void> register(
      {required String email,
      required String password,
      required String phone}) async {
    await DBHelper.registerUser(
      UserModel(
        email: email,
        password: password,
        phone: phone,
      ),
    );

    PreferenceHandler().storingIsLogin(true);
    PreferenceHandler().storingUserEmail(email);
  }

  // Mengambil email user yang tersimpan di local storage (preferences).
  Future<String?> getUserEmail() async {
    return await PreferenceHandler.getUserEmail();
  }

  // Mengambil detail data user yang sedang login dari database.
  Future<UserModel?> getCurrentUser() async {
    // 1. Ambil email dari local storage
    final email = await PreferenceHandler.getUserEmail();

    if (email == null) return null;

    // 2. Cari user di database berdasarkan email tersebut
    final db = await DBHelper.database();

    final result = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    // 3. Kembalikan data user jika ditemukan
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }

    return null;
  }
}
