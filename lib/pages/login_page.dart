import 'package:drivora_autoquest/components/my_button.dart';
import 'package:drivora_autoquest/components/square_tile.dart';
import 'package:drivora_autoquest/components/my_textfield.dart';
import 'package:drivora_autoquest/pages/forgotPasswordPage.dart';
import 'package:drivora_autoquest/pages/signupPage.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/auth_service.dart';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:drivora_autoquest/pages/mainPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? emailError;

  @override
  void initState() {
    super.initState();

    usernameController.addListener(() {
      final email = usernameController.text.trim();
      if (email.isEmpty) {
        setState(() {
          emailError = "Email is required";
        });
      } else if (!email.contains('@') ||
          !RegExp(
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
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Future<void> _handleEmailLogin(BuildContext context) async {
  //   if (emailError != null) return;

  //   final email = usernameController.text.trim();
  //   final password = passwordController.text.trim();

  //   if (email.isEmpty || password.isEmpty) {
  //     DialogHelper.showErrorDialog(
  //       context,
  //       "Email and password cannot be empty.",
  //     );
  //     return;
  //   }

  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     DialogHelper.showErrorDialog(context, "No internet connection.");
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(child: CircularProgressIndicator()),
  //   );

  //   try {
  //     UserCredential user = await _authService.signInWithEmailAndPassword(
  //       email,
  //       password,
  //     );
  //     if (context.mounted) Navigator.pop(context);

  //     DialogHelper.showSuccessDialog(
  //       context,
  //       "Welcome, ${user.user?.email}!",
  //       onContinue: () {
  //         Get.off(() => MainPage());
  //       },
  //     );
  //   } catch (e) {
  //     if (context.mounted) Navigator.pop(context);
  //     DialogHelper.showErrorDialog(context, e.toString());
  //   }
  // }

  Future<void> _handleEmailLogin(BuildContext context) async {
    if (emailError != null) return;

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      DialogHelper.showErrorDialog(
        context,
        "Email and password cannot be empty.",
      );
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
      UserCredential user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      await UserService(
        api: apiConnection,
      ).addUserIfNotExists(uid: user.user!.uid, email: user.user!.email!);

      if (context.mounted) Navigator.pop(context);

      DialogHelper.showSuccessDialog(
        context,
        "Welcome, ${user.user?.email}!",
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
                            'Login to your Account',
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
                        controller: usernameController,
                        labelText: 'Email',
                        obscureText: false,
                        errorText: emailError,
                      ),
                      const SizedBox(height: 25),
                      MyTextfield(
                        controller: passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Get.to(() => ForgotPasswordPage());

                              Get.to(
                                () => ForgotPasswordPage(),
                                transition: Transition.rightToLeft,
                                duration: Duration(milliseconds: 400),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFFFF7A30),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      MyButton(
                        text: 'Login',
                        buttonWidth: 300,
                        onPressed: () async {
                          await _handleEmailLogin(context);
                        },
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Or login with',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SquareTile(
                      //   onTap: () async {
                      //     try {
                      //       UserCredential user = await _authService
                      //           .signInWithGoogle();
                      //       DialogHelper.showSuccessDialog(
                      //         context,
                      //         "Welcome, ${user.user?.displayName}!",
                      //         onContinue: () {
                      //           Get.off(
                      //             () => MainPage(),
                      //             transition: Transition.fade,
                      //             duration: Duration(milliseconds: 1100),
                      //           );
                      //         },
                      //       );
                      //     } catch (e) {
                      //       DialogHelper.showErrorDialog(context, e.toString());
                      //     }
                      //   },
                      // ),
                      SquareTile(
                        onTap: () async {
                          try {
                            UserCredential user = await _authService
                                .signInWithGoogle();

                            await UserService(
                              api: apiConnection,
                            ).addUserIfNotExists(
                              uid: user.user!.uid,
                              email: user.user!.email!,
                            );

                            DialogHelper.showSuccessDialog(
                              context,
                              "Welcome, ${user.user?.displayName}!",
                              onContinue: () {
                                Get.off(
                                  () => MainPage(),
                                  transition: Transition.fade,
                                  duration: Duration(milliseconds: 1100),
                                );
                              },
                            );
                          } catch (e) {
                            DialogHelper.showErrorDialog(context, e.toString());
                          }
                        },
                      ),

                      const SizedBox(height: 70),
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Color(0xFFFF7A30),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.off(
                                    () => SignUpPage(),
                                    transition: Transition.rightToLeft,
                                    duration: Duration(milliseconds: 400),
                                  );

                                  // Get.off(() => SignUpPage());
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
