import 'package:get/get.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class PenindakHomepageController extends GetxController {
  final AuthSharedPreferences _authPrefs = AuthSharedPreferences();

  RxString username = 'User'.obs;
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final name = await _authPrefs.getUsername();
      if (name != null) {
        username.value = name;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> logout() async {
    // Clear local storage
    await _authPrefs.clear();

    // Delete all GetX controllers to clear cached data
    Get.deleteAll();
  }
}
