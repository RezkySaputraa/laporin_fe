import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:laporin_app/models/login_google_model.dart';
import 'package:laporin_app/models/login_model.dart';
import 'package:laporin_app/services/login_service.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';
import 'package:laporin_app/services/supabase/supabase_service.dart';

class ProfileGoogleController extends GetxController {
  final LoginService loginService = LoginService();

  RxBool obscureText = true.obs;
  RxBool isFetchingUser = false.obs;

  Future<bool> getUserProfile() async {
    try {
      isFetchingUser.value = true;
      final data = await laporinService.getJenisLaporan();
      final list = (data)
          .map((json) => LaporinJenisModel.fromJson(json))
          .toList();
      jenisList.value = list;
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoadingJenis.value = false;
    }
  }
}
