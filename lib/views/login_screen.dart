import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/controllers/login_controller.dart';
import 'package:laporin_app/views/profile_google_screen.dart';
import 'package:laporin_app/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late LoginController loginController;

  @override
  void initState() {
    super.initState();
    // Use Get.put with permanent: false, or find existing
    loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
    // Reset form state when entering screen
    loginController.resetForm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Welcome",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 33,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F55C7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Aplikasi Cerdas untuk Masyarakat Melapor Kejadian.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4C4B4B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: loginController.emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                            hintText: "Email...",
                            hintStyle: GoogleFonts.inter(
                              color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF0F55C7)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => TextFormField(
                            controller: loginController.passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password wajib diisi";
                              }
                              return null;
                            },
                            textAlign: TextAlign.start,
                            obscureText: loginController.obscureText.value,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF3F3F3),
                              hintText: "Password...",
                              hintStyle: GoogleFonts.inter(
                                color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Color(0xFF0F55C7),
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  loginController.obscureText.value =
                                      !loginController.obscureText.value;
                                },
                                icon: loginController.obscureText.value
                                    ? Icon(Icons.visibility)
                                    : Icon(
                                        Icons.visibility_off,
                                        color: Color(
                                          0xFF4C4B4B,
                                        ).withValues(alpha: 0.8),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w200,
                              color: Color(0xFF4C4B4B).withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loginController.isLoading.value
                                  ? null
                                  : () async {
                                      FocusScope.of(context).unfocus();

                                      final isFormValid =
                                          _formKey.currentState
                                                  ?.validate() ??
                                              false;

                                      if (!isFormValid) return;

                                      final result = await loginController
                                          .loginUser();

                                      if (result == true) {
                                        loginController.resetForm();

                                        if (mounted) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProfileGoogleScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Login Gagal"),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 32,
                                ),
                                backgroundColor: Color(0xFF0F55C7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              child: loginController.isLoading.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Sign In",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Or continue with",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Color(0xFF4C4B4B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final bool result = await loginController
                                .continueWithGoogle(context);
                            if (result == true) {
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileGoogleScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Login Gagal")),
                                );
                              }
                            }
                          },
                          icon: SvgPicture.asset(
                            "assets/images/login_screen/google.svg",
                          ),
                          label: Text(
                            "Google",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF4C4B4B),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF3F3F3),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: _navigateToRegister,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0),
                              ),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.inter(
                                  color: Color(0xFF0F55C7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
