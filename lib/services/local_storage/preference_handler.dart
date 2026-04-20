import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferenceHandler {
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  Future<void> init() async {
    // Inisialisasi SharedPreferences
    _preferences = await SharedPreferences.getInstance();
  }

  static const String _isLogin = 'isLogin';
  static const String _userEmail = 'userEmail';
  static const String _notificationsKey = 'notifications_list';

  Future<void> storingIsLogin(bool isLogin) async {
    // Simpan status login
    await _preferences.setBool(_isLogin, isLogin);
  }

  Future<void> storingUserEmail(String? email) async {
    // Simpan email user
    await _preferences.setString(_userEmail, email ?? "");
  }

  static Future<bool?> getIsLogin() async {
    // Ambil status login
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLogin);
  }

  static Future<String?> getUserEmail() async {
    // Ambil email user
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  Future<void> addNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Tambah notifikasi ke local storage
    SharedPreferences prefs;
    try {
      prefs = _preferences;
    } catch (_) {
      // fallback jika init() belum dipanggil
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
    // Ambil semua notifikasi dari local storage
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_notificationsKey) ?? <String>[];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  static Future<void> clearNotifications() async {
    // Hapus semua notifikasi dari local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  Future<void> deleteIsLogin() async {
    // Hapus status login
    await _preferences.remove(_isLogin);
  }

  Future<void> deleteUserEmail() async {
    // Hapus email user
    await _preferences.remove(_userEmail);
  }
}
