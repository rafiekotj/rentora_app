import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/sqflite.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class UserController {
  // =========================
  // REGISTER
  // =========================
  static Future<bool> register({
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserModel user = UserModel(
        email: email,
        password: password,
        phone: phone,
      );

      await DBHelper.registerUser(user);

      return true;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // LOGIN
  // =========================
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    return await DBHelper.loginUser(email: email, password: password);
  }

  static Future<String?> getUserEmail() async {
    return await PreferenceHandler.getUserEmail();
  }

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
}
