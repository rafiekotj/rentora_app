import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferenceHandler {
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const String _isLogin = 'isLogin';
  static const String _userEmail = 'userEmail';
  static const String _notificationsKey = 'notifications_list';

  Future<void> storingIsLogin(bool isLogin) async {
    _preferences.setBool(_isLogin, isLogin);
  }

  Future<void> storingUserEmail(String? email) async {
    _preferences.setString(_userEmail, email ?? "");
  }

  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getBool(_isLogin);
    return data;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  Future<void> addNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    SharedPreferences prefs;
    try {
      prefs = _preferences;
    } catch (_) {
      // fallback if init() hasn't been called yet
      prefs = await SharedPreferences.getInstance();
    }

    final list = prefs.getStringList(_notificationsKey) ?? <String>[];
    final entry = {
      'title': title,
      'body': body,
      'data': data ?? {},
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.insert(0, jsonEncode(entry));
    await prefs.setStringList(_notificationsKey, list);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_notificationsKey) ?? <String>[];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }

  Future<void> deleteUserEmail() async {
    await _preferences.remove(_userEmail);
  }
}
