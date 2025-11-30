import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome",
              style: GoogleFonts.inter(
                fontSize: 33,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C4B4B),
              ),
            ),
            Text(
              "Aplikasi Cerdas untuk Masyarakat Melapor Kejadian.",
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color(0xFF4C4B4B),
              ),
              textAlign: TextAlign.center,
            ),
            TextField(
              textAlign: TextAlign.start,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEFEFEF), // warna background
                hintText: "Search movies...",
                hintStyle: const TextStyle(
                  color: Color(0xFF4C4B4B),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF4C4B4B),
                fontSize: 14,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
            TextField(
              textAlign: TextAlign.start,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEFEFEF), // warna background
                hintText: "Search movies...",
                hintStyle: const TextStyle(
                  color: Color(0xFF4C4B4B),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF4C4B4B),
                fontSize: 14,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF4C4B4B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                backgroundColor: Color(0xFF4C4B4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Login",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Text(
              "Or continue with",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color(0xFF4C4B4B),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                backgroundColor: Color(0xFF4C4B4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Google",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // hilangkan padding default
                  ),
                  onPressed: () {},
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Color(0xFF0F55C7)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
