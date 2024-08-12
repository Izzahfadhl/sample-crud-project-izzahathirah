import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:daylog/colors/app_colors.dart';
import 'package:daylog/pages/diary_page.dart';
import 'package:daylog/pages/favourite_page.dart';
import 'package:daylog/pages/reminder_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentPage),
      //backgroundColor: const Color(0xffFFF8E1),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xffFFFFFF),
        color: const Color(0xffFFCCBC),
        animationDuration: const Duration(microseconds: 300),
        index: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: const [
          Icon(
            Icons.border_color_rounded,
            color: AppColors.charcoal,
          ),
          Icon(
            Icons.favorite,
            color: AppColors.charcoal,
          ),
          Icon(
            Icons.app_registration_rounded,
            color: AppColors.charcoal,
          ),
        ],
      ),
    );
  }

  Widget _getPage(int page) {
    switch (page) {
      case 0:
        return const DiaryPage();
      case 1:
        return const FavouritePage();
      case 2:
        return const ReminderPage();
      default:
        return const ReminderPage();
    }
  }
}
