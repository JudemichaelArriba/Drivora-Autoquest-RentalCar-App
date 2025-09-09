import 'package:drivora_autoquest/components/my_button.dart';
import 'package:drivora_autoquest/components/my_textfield.dart';
import 'package:drivora_autoquest/pages/login_page.dart';
import 'package:drivora_autoquest/services/auth_service.dart';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:drivora_autoquest/pages/mainPage.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? emailError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        setState(() {
          emailError = "Email is required";
        });
      } else if (!RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
      ).hasMatch(email)) {
        setState(() {
          emailError = "Invalid email address";
        });
      } else {
        setState(() {
          emailError = null;
        });
      }
    });

    confirmPasswordController.addListener(() {
      final password = passwordController.text.trim();
      final confirm = confirmPasswordController.text.trim();
      if (confirm.isEmpty) {
        setState(() {
          confirmPasswordError = null;
        });
      } else if (confirm != password) {
        setState(() {
          confirmPasswordError = "Passwords do not match";
        });
      } else {
        setState(() {
          confirmPasswordError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      DialogHelper.showErrorDialog(context, "All fields are required.");
      return;
    }

    if (emailError != null || confirmPasswordError != null) {
      DialogHelper.showErrorDialog(context, "Please fix the errors.");
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      DialogHelper.showErrorDialog(context, "No internet connection.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );
      if (context.mounted) Navigator.pop(context);

      DialogHelper.showSuccessDialog(
        context,
        "Account created for ${user.user?.email}!",
        onContinue: () {
          Get.off(() => MainPage());
        },
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      DialogHelper.showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 35),
                      Center(
                        child: Image.asset(
                          'lib/images/car logo.png',
                          height: 80,
                          width: 270,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Text(
                        'Drivora Autoquest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFF7A30),
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Create a New Account',
                            style: const TextStyle(
                              color: Color(0xFF505050),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextfield(
                        controller: emailController,
                        labelText: 'Email',
                        obscureText: false,
                        errorText: emailError,
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
                        controller: passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
                        controller: confirmPasswordController,
                        labelText: 'Confirm Password',
                        obscureText: true,
                        errorText: confirmPasswordError,
                      ),
                      const SizedBox(height: 30),
                      MyButton(
                        text: 'Sign Up',
                        onPressed: () async {
                          await _handleSignUp(context);
                        },
                      ),
                      const SizedBox(height: 140),
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: const TextStyle(
                                color: Color(0xFFFF7A30),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.off(
                                    () => LoginPage(),
                                    transition: Transition.leftToRight,
                                    duration: Duration(milliseconds: 400),
                                  );

                                  // Get.off(() => LoginPage());
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
