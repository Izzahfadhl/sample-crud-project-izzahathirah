import 'package:daylog/colors/app_colors.dart';
import 'package:daylog/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF4081),
              Color(0xFFFF6D00),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(45.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                'DaylOg',
                style: GoogleFonts.crimsonText(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Image.asset(
                  'images/diary.png',
                  height: 300,
                  width: 300,
                ),
              ),
              Center(
                child: Text(
                  'Capture Today,',
                  style: GoogleFonts.whisper(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Cherish Tomorrow',
                  style: GoogleFonts.whisper(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                'Write, reflect, and remember with every entry.',
                style: GoogleFonts.crimsonText(
                  fontSize: 22,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Log Your Thoughts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
