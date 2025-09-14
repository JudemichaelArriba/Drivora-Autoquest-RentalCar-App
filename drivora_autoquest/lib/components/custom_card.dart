import 'package:flutter/material.dart';
import 'package:flutter_advanced_cards/flutter_advanced_cards.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String price;
  final VoidCallback onButtonPressed;

  const CustomCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedCard(
      fullWidth: true,
      height: 250,
      borderRadius: 20,
      cardImage: imageUrl,
      imagePosition: ImagePosition.background,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 150,
            child: Text(
              title,
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
            bottom: -10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$price /per day",
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
                    minimumSize: const Size(80, 30),
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
    );
  }
}
