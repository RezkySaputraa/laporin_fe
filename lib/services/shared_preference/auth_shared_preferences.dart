import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSharedPreferences {
  static const authKey = "auth_key";
  SharedPreferences? _sharedPreferences;

  AuthSharedPreferences() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    if (_sharedPreferences != null) return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveUser({
    required int id,
    required String username,
    required String login,
  }) async {
    await _initSharedPreferences();

    final data = jsonEncode({"id": id, "username": username, "login": login});

    await _sharedPreferences!.setString(authKey, data);
  }

  Future<Map<String, dynamic>?> getUser() async {
    await _initSharedPreferences();

    final data = _sharedPreferences!.getString(authKey);
    if (data == null) return null;

    return jsonDecode(data);
  }

  Future<int?> getUserId() async {
    final user = await getUser();
    return user?['id'];
  }

  Future<String?> getUsername() async {
    final user = await getUser();
    return user?['username'];
  }

  Future<String?> getLogin() async {
    final user = await getUser();
    return user?['login'];
  }

  // LOGOUT
  Future<void> clear() async {
    await _initSharedPreferences();
    await _sharedPreferences!.remove(authKey);
  }
}
