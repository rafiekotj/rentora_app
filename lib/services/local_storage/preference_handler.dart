import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  // ===============================
  // SINGLETON (hanya 1 instance)
  // ===============================

  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  // ===============================
  // INIT SHARED PREFERENCES
  // dipanggil di main.dart
  // ===============================

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // ===============================
  // KEY
  // ===============================

  static const String _isLogin = 'isLogin';
  static const String _userEmail = 'userEmail';

  // ===============================
  // CREATE / SAVE DATA
  // ===============================

  // menyimpan status login
  Future<void> storingIsLogin(bool isLogin) async {
    _preferences.setBool(_isLogin, isLogin);
  }

  // menyimpan email user yang login
  Future<void> storingUserEmail(String? email) async {
    _preferences.setString(_userEmail, email ?? "");
  }

  // ===============================
  // GET DATA
  // ===============================

  // mengambil status login
  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getBool(_isLogin);
    return data;
  }

  // mengambil email user yang login
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  // ===============================
  // DELETE DATA
  // ===============================

  // menghapus status login
  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }

  // menghapus email user
  Future<void> deleteUserEmail() async {
    await _preferences.remove(_userEmail);
  }
}
