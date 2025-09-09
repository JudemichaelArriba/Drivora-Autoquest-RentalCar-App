import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../components/navigation_controller.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final NavigationController navController = Get.find();
  final Color accentColor = const Color(0xFFFF7A30);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: GNav(
                    rippleColor: Colors.grey.shade300,
                    hoverColor: Colors.grey.shade100,
                    haptic: true,
                    tabBorderRadius: 25,
                    tabActiveBorder: Border.all(color: accentColor, width: 1),
                    tabBorder: Border.all(color: Colors.transparent, width: 0),
                    tabShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    curve: Curves.easeOutExpo,
                    duration: const Duration(milliseconds: 300),
                    gap: 5,
                    color: Colors.grey.shade600,
                    activeColor: accentColor,
                    iconSize: 24,
                    tabBackgroundColor: accentColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    selectedIndex: navController.selectedIndex.value,
                    onTabChange: navController.changeTab,
                    tabs: const [
                      GButton(icon: Icons.home, text: 'Home'),
                      GButton(icon: Icons.directions_car, text: 'Cars'),
                      GButton(icon: Icons.book, text: 'Bookings'),
                      GButton(icon: Icons.payment, text: 'Payments'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
