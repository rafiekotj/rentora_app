import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  // Inisialisasi Shared Preference
  static final PreferenceHandler _instance = PreferenceHandler._internal();

  // Key user
  static const String _isLogin = 'isLogin';

  static const String _userEmail = 'userEmail';

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // CREATE
  Future<void> storingIsLogin(bool isLogin) async {
    _preferences.setBool(_isLogin, isLogin);
  }

  Future<void> storingUserEmail(String email) async {
    _preferences.setString(_userEmail, email);
  }

  // GET
  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();

    var data = prefs.getBool(_isLogin);
    return data;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  // DELETE
  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }

  Future<void> deleteUserEmail() async {
    await _preferences.remove(_userEmail);
  }
}
