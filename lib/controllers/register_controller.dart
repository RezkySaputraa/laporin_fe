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

      await registerService.register(registerData);
      return true;
    } catch (e) {
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
