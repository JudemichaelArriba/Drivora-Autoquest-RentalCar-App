import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? emailError;

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      final email = emailController.text.trim();
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
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (emailError != null) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      DialogHelper.showErrorDialog(context, "Please enter your email");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      DialogHelper.showSuccessDialog(
        context,
        "Password reset link sent to $email",
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        DialogHelper.showErrorDialog(
          context,
          "No account found for this email.",
        );
      } else if (e.code == 'invalid-email') {
        DialogHelper.showErrorDialog(
          context,
          "The email address is not valid.",
        );
      } else {
        DialogHelper.showErrorDialog(
          context,
          e.message ?? "Something went wrong.",
        );
      }
    } catch (e) {
      debugPrint("🔥 Firebase Reset Password Error: $e");
      DialogHelper.showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF7A30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7A30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 100),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "Enter your email to receive a password reset link.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 128, 128, 128),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              MyTextfield(
                controller: emailController,
                labelText: "Email",
                obscureText: false,
                errorText: emailError,
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _resetPassword(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
