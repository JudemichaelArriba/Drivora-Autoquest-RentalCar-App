import 'package:flutter/material.dart';

class Widgetsearchbar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final double? height;
  final double? width;
  final double? borderRadius; // new optional parameter

  const Widgetsearchbar({
    super.key,
    this.hintText = "Search...",
    this.onChanged,
    this.controller,
    this.height,
    this.width,
    this.borderRadius, // accept borderRadius
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight = height ?? 50;
    final double radius = borderRadius ?? 30; // default radius 30

    return Container(
      height: barHeight,
      width: width ?? double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: barHeight / 4,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
