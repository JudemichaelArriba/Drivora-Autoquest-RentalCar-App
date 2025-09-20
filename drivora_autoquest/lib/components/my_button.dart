import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? cornerRadius;
  final double? buttonWidth;
  final double? buttonHeight;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.cornerRadius,
    this.buttonWidth,
    this.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: buttonWidth ?? double.infinity,
        height: buttonHeight ?? 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius ?? 5),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
