import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laporin_app/views/login_screen.dart';
import 'package:laporin_app/views/opening_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const OpeningScreen();
  }
}
