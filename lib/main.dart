// import 'package:drivora_autoquest/pages/login_page.dart';
// import 'package:drivora_autoquest/components/onboardingScreen.dart';
import 'package:drivora_autoquest/services/authWrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      home: const AuthWrapper(),
    );
  }
}
