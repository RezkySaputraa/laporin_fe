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

class LoginController extends GetxController {
  final LoginService loginService = LoginService();
  final SupabaseService supabaseService = SupabaseService();

  final AuthSharedPreferences authPrefs = AuthSharedPreferences();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool isLoading = false.obs;
  RxInt userRoles = 0.obs; // 1 = penindak, 2 = masyarakat

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> continueWithGoogle(context) async {
    try {
      isLoading.value = true;
      GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId: dotenv.env['WEB_CLIENT'],
        clientId: Platform.isAndroid
            ? dotenv.env['ANDROID_CLIENT']
            : dotenv.env['IOS_CLIENT'],
      );

      GoogleSignInAccount account = await signIn.authenticate();
      String idToken = account.authentication.idToken ?? '';
      final authorization =
          await account.authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]) ??
          await account.authorizationClient.authorizeScopes([
            'email',
            'profile',
          ]);

      final result = await supabaseService.signInWithGoogle(
        idToken,
        authorization.accessToken,
      );

      if (result.user != null && result.session != null) {
        final user = result.user!;

        final data = LoginGoogleModel(
          username: user.userMetadata!['full_name'] ?? 'User Google',
          email: user.email ?? 'dummy@gmail.com',
        );

        final response = await loginService.loginFromGoogle(data);

        if (response.isNotEmpty) {
          final userData = response[0];

          await authPrefs.saveUser(
            id: userData['id'],
            username: userData['username'],
            login: "google",
            roles: userData['roles'] ?? 0,
          );
          userRoles.value = userData['roles'] ?? 0;

          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginUser() async {
    try {
      isLoading.value = true;
      final loginData = LoginModel(
        email: emailController.text,
        password: passwordController.text,
      );
      final result = await loginService.login(loginData);

      await authPrefs.saveUser(
        id: result['id'],
        username: result['username'],
        login: "password",
        roles: result['roles'] ?? 0,
      );
      userRoles.value = result['roles'] ?? 0;

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
