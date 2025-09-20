import 'package:drivora_autoquest/pages/login_page.dart';
import 'package:drivora_autoquest/components/onboardingScreen.dart';
import 'package:drivora_autoquest/pages/mainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? seenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingSeen();
  }

  Future<void> _checkOnboardingSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      seenOnboarding = prefs.getBool('onboarding_completed') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (seenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainPage();
        }

        return seenOnboarding! ? const LoginPage() : const OnboardingScreen();
      },
    );
  }
}
