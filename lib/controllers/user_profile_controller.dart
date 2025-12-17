import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/services/profile_service.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class UserProfileController extends GetxController {
  final ProfileService profileService = ProfileService();
  final AuthSharedPreferences authPrefs = AuthSharedPreferences();

  RxBool isFetchingUser = false.obs;
  RxBool isUpdating = false.obs;
  RxInt idUser = 0.obs;

  RxString username = "".obs;
  RxString email = "".obs;
  RxString password = "".obs;

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loadUser();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void loadUser() async {
    final id = await authPrefs.getUserId();
    idUser.value = id!.toInt();
    await getUserProfile();
  }

  Future<bool> getUserProfile() async {
    try {
      isFetchingUser.value = true;
      final data = await profileService.getProfile(idUser.value);
      username.value = data['username'] ?? '';
      email.value = data['email'] ?? '';

      usernameController.text = username.value;
      emailController.text = email.value;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isFetchingUser.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isUpdating.value = true;

      final updateData = {
        'username': usernameController.text,
        'email': emailController.text,
      };

      // Hanya tambahkan password jika diisi
      if (passwordController.text.isNotEmpty) {
        updateData['password'] = passwordController.text;
      }

      final result = await profileService.updateProfile(
        idUser.value,
        updateData,
      );

      if (result) {
        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear password field setelah berhasil update
        passwordController.clear();

        // Reload profile data
        await getUserProfile();
      } else {
        Get.snackbar(
          'Error',
          'Gagal memperbarui profil',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    // Password bersifat optional saat update
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }
}
