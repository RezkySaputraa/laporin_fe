import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/models/login_model.dart';
import 'package:laporin_app/services/login_service.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class LoginController extends GetxController {
  final LoginService loginService = LoginService();
  final AuthSharedPreferences authPrefs = AuthSharedPreferences();

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> loginUser() async {
    try {
      isLoading.value = true;
      final loginData = LoginModel(
        email: emailController.text,
        password: passwordController.text,
      );
      final result = await loginService.login(loginData);

      await authPrefs.saveUser(id: result['id'], username: result['username']);

      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    emailController.text = '';
    passwordController.text = '';

    obscureText.value = true;
    isLoading.value = false;
  }
}
