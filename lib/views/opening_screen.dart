import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Column(
              children: [
                SvgPicture.asset(
                  'assets/images/opening_screen/logo.svg',
                  height: 90,
                  width: 80,
                ),
                Text(
                  'LaporinAja',
                  style: GoogleFonts.inter(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C4B4B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'from',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF4C4B4B),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/opening_screen/sync.svg',
                  height: 23,
                  width: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
