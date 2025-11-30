import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/views/splash_screen.dart';

void main() {
  runApp(LaporinAja());
}

class LaporinAja extends StatelessWidget {
  const LaporinAja({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Laporin Aja App",
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
