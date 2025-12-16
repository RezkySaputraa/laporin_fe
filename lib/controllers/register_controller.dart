import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/models/register_model.dart';
import 'package:laporin_app/services/register_service.dart';

class RegisterController extends GetxController {
  final RegisterService registerService = RegisterService();

  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool isLoading = false.obs;

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
      final registerData = RegisterModel(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      await registerService.register(registerData);

      return true;
    } catch (e) {
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
  }
}
