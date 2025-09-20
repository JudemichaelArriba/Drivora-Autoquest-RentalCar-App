import 'package:drivora_autoquest/pages/favoritesPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/navigation_controller.dart';
import '../components/bottomNavBar.dart';
import 'homePage.dart';

import 'bookingsPage.dart';
import 'paymentsPage.dart';
import 'profilePage.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> pages = [
    const HomePage(),
    const FavoritesPage(),
    const BookingsPage(),
    const PaymentsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: Obx(() => pages[navController.selectedIndex.value]),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
