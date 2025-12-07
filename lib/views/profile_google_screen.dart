import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileGoogleScreen extends StatelessWidget {
  const ProfileGoogleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            color: Color(0xFF0F55C7),
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    "assets/images/profile_screen/demo-image.png",
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C4B4B),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                readOnly: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: "Username...",
                  hintStyle: GoogleFonts.inter(
                    color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF0F55C7)),
                  ),
                ),
                style: GoogleFonts.inter(
                  color: Color(0xFF4C4B4B),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "E-mail",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C4B4B),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                readOnly: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: "Email...",
                  hintStyle: GoogleFonts.inter(
                    color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF0F55C7)),
                  ),
                ),
                style: GoogleFonts.inter(
                  color: Color(0xFF4C4B4B),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    backgroundColor: Color(0xFF0F55C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/images/login_screen/google.svg"),
                      SizedBox(width: 10),
                      Text(
                        "Service by Google",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
