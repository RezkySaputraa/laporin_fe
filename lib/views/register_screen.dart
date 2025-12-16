import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/controllers/register_controller.dart';
import 'package:laporin_app/views/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late RegisterController registerController;

  @override
  void initState() {
    super.initState();
    // Use Get.put or find existing
    registerController = Get.isRegistered<RegisterController>()
        ? Get.find<RegisterController>()
        : Get.put(RegisterController());
    // Reset form state when entering screen
    registerController.resetForm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
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
                          "Sign up",
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

                        // Username Field
                        TextFormField(
                          controller: registerController.usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Username wajib diisi";
                            }
                            return null;
                          },
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                            hintText: "Username",
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

                        // Email Field
                        TextFormField(
                          controller: registerController.emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                            hintText: "E-mail",
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

                        // Password Field
                        Obx(
                          () => TextFormField(
                            controller: registerController.passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password wajib diisi";
                              }
                              if (value.length < 6) {
                                return "Password minimal 6 karakter";
                              }
                              return null;
                            },
                            textAlign: TextAlign.start,
                            obscureText: registerController.obscureText.value,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF3F3F3),
                              hintText: "Password",
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
                                  registerController.obscureText.value =
                                      !registerController.obscureText.value;
                                },
                                icon: registerController.obscureText.value
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
                        const SizedBox(height: 30),

                        // Sign Up Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: registerController.isLoading.value
                                  ? null
                                  : () async {
                                      FocusScope.of(context).unfocus();

                                      final isFormValid = _formKey
                                              .currentState
                                              ?.validate() ??
                                          false;

                                      if (!isFormValid) return;

                                      final result = await registerController
                                          .registerUser();

                                      if (result == true) {
                                        registerController.resetForm();

                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Registrasi berhasil! Silakan login.",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          _navigateToLogin();
                                        }
                                      } else {
                                        if (mounted) {
                                          final errorMsg = registerController
                                              .errorMessage.value;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                errorMsg.isNotEmpty
                                                    ? errorMsg
                                                    : "Registrasi Gagal",
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 5),
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
                              child: registerController.isLoading.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Sign up",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Already have account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?"),
                            TextButton(
                              onPressed: _navigateToLogin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0),
                              ),
                              child: Text(
                                "Sign In",
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
