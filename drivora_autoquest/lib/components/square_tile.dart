import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final VoidCallback onTap;
  const SquareTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/images/Google_Symbol_1.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                color: Color.fromARGB(255, 41, 32, 32),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
