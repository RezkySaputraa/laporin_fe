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
    required int roles, // 1 = penindak, 2 = masyarakat
  }) async {
    await _initSharedPreferences();

    final data = jsonEncode({
      "id": id,
      "username": username,
      "login": login,
      "roles": roles,
    });

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

  /// Get user roles
  /// 1 = penindak, 2 = masyarakat
  Future<int?> getRoles() async {
    final user = await getUser();
    return user?['roles'];
  }

  /// Check if user is penindak (roles = 1)
  Future<bool> isPenindak() async {
    final roles = await getRoles();
    return roles == 1;
  }

  // LOGOUT
  Future<void> clear() async {
    await _initSharedPreferences();
    await _sharedPreferences!.remove(authKey);
  }
}
