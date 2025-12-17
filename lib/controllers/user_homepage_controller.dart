import 'package:get/get.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class UserHomepageController extends GetxController {
  final AuthSharedPreferences authPrefs = AuthSharedPreferences();
  
  RxString username = 'User'.obs;
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final name = await authPrefs.getUsername();
    if (name != null) {
      username.value = name;
    }
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> logout() async {
    await authPrefs.clear();
  }
}
