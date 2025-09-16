import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String rentPrice;
  final VoidCallback onButtonPressed;

  const CustomCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rentPrice,
    required this.onButtonPressed,
  });

  bool get _isBase64 =>
      imageUrl.isNotEmpty &&
      !imageUrl.startsWith("http") &&
      !imageUrl.startsWith("https");

  @override
  Widget build(BuildContext context) {
    Widget background;

    if (_isBase64) {
      try {
        Uint8List bytes = base64Decode(
          imageUrl.contains(",") ? imageUrl.split(",").last : imageUrl,
        );
        background = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        background = Image.network(
          "https://via.placeholder.com/150",
          fit: BoxFit.cover,
        );
      }
    } else {
      background = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 150,
              right: 16, // ✅ Added to constrain text width
              child: Text(
                title,
                maxLines: 1, // ✅ Limit to 1 line
                overflow: TextOverflow.ellipsis, // ✅ Show "..." if too long
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 16,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$rentPrice /per day",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      minimumSize: const Size(80, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.book, color: Colors.white, size: 18),
                    label: const Text(
                      "Book Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
