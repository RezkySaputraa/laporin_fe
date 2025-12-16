import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/models/register_model.dart';
import 'package:laporin_app/services/register_service.dart';

class RegisterController extends GetxController {
  final RegisterService registerService = RegisterService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> registerUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final registerData = RegisterModel(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      debugPrint('=== REGISTER DEBUG ===');
      debugPrint('Username: ${registerData.username}');
      debugPrint('Email: ${registerData.email}');
      debugPrint('Password length: ${registerData.password.length}');
      debugPrint('Request data: ${registerData.toJson()}');
      
      final result = await registerService.register(registerData);
      
      debugPrint('Register success: $result');
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    usernameController.text = '';
    emailController.text = '';
    passwordController.text = '';

    obscureText.value = true;
    isLoading.value = false;
    errorMessage.value = '';
  }
}
