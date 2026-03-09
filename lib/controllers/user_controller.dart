import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

class UserController {
  final PreferenceHandler _preferenceHandler = PreferenceHandler();

  Future<void> register(UserModel user) async {
    await DBHelper.registerUser(user);
  }

  Future<bool> login({required String email, required String password}) async {
    final user = await DBHelper.loginUser(email: email, password: password);

    if (user != null) {
      await _preferenceHandler.storingIsLogin(true);
      await _preferenceHandler.storingUserEmail(user.email);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _preferenceHandler.deleteIsLogin();
    await _preferenceHandler.deleteUserEmail();
  }

  Future<bool> isUserLoggedIn() async {
    return await PreferenceHandler.getIsLogin() ?? false;
  }
}
