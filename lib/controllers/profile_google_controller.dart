import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/services/profile_service.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class ProfileGoogleController extends GetxController {
  final ProfileService profileService = ProfileService();
  final AuthSharedPreferences authPrefs = AuthSharedPreferences();

  RxBool isFetchingUser = false.obs;
  RxInt idUser = 0.obs;

  RxString username = "".obs;
  RxString email = "".obs;

  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    loadUser();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
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
      username.value = data['username'];
      email.value = data['email'];

      usernameController.text = username.value;
      emailController.text = email.value;
      return true;
    } catch (e) {
      return false;
    } finally {
      isFetchingUser.value = false;
    }
  }
}
