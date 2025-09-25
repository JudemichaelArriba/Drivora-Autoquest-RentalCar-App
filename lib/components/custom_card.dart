import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';

class CustomCard extends StatefulWidget {
  final int carId;
  final String title;
  final String imageUrl;
  final String rentPrice;
  final bool favorites;
  final String status;
  final VoidCallback onButtonPressed;
  final ValueChanged<bool>? onFavoriteChanged;

  const CustomCard({
    super.key,
    required this.carId,
    required this.title,
    required this.imageUrl,
    required this.rentPrice,
    required this.favorites,
    required this.status,
    required this.onButtonPressed,
    this.onFavoriteChanged,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late bool _isFavorite;
  Uint8List? _decodedImage;

  bool get _isBase64 =>
      widget.imageUrl.isNotEmpty &&
      !widget.imageUrl.startsWith("http") &&
      !widget.imageUrl.startsWith("https");

  bool get _isBooked => widget.status.toLowerCase() == "booked";

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.favorites;
    _decodedImage = _isBase64 ? _decodeImage(widget.imageUrl) : null;
  }

  @override
  void didUpdateWidget(CustomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favorites != widget.favorites) {
      _isFavorite = widget.favorites;
    }
  }

  Uint8List? _decodeImage(String imageUrl) {
    try {
      return base64Decode(
        imageUrl.contains(",") ? imageUrl.split(",").last : imageUrl,
      );
    } catch (e) {
      return null;
    }
  }

  // Future<void> _toggleFavorite() async {
  //   if (_isBooked) return;
  //   final carService = CarService(api: apiConnection);
  //   //new changes here
  //   final String? uid = FirebaseAuth.instance.currentUser?.uid;
  //   //new changes here
  //   setState(() {
  //     _isFavorite = !_isFavorite;
  //   });

  //   if (uid == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
  //     return;
  //   }

  //   try {
  //     bool success;
  //     if (_isFavorite) {
  //       success = await carService.unmarkAsFavorite(uid, widget.carId);
  //     } else {
  //       success = await carService.markAsFavorite(uid, widget.carId);
  //     }

  //     if (success) {
  //       setState(() {
  //         _isFavorite = !_isFavorite;
  //       });
  //       widget.onFavoriteChanged?.call(_isFavorite);
  //     }
  //   } catch (e) {
  //     print("Error toggling favorite: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Failed to update favorite")),
  //     );
  //   }
  // }

  Future<void> _toggleFavorite() async {
    if (_isBooked) return;
    final carService = CarService(api: apiConnection);
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    try {
      bool success;
      if (_isFavorite) {
        success = await carService.unmarkAsFavorite(uid, widget.carId);
      } else {
        success = await carService.markAsFavorite(uid, widget.carId);
      }

      if (success) {
        setState(() {
          _isFavorite = !_isFavorite; // 👈 flip only after success
        });
        widget.onFavoriteChanged?.call(_isFavorite);
      }
    } catch (e) {
      print("Error toggling favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update favorite")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget background;
    if (_isBase64 && _decodedImage != null) {
      background = Image.memory(
        _decodedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      background = Image.network(
        widget.imageUrl.isNotEmpty
            ? widget.imageUrl
            : "https://via.placeholder.com/150",
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
              right: 50,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _isBooked ? null : _toggleFavorite,
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
                    "${widget.rentPrice} /per day",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isBooked ? null : widget.onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBooked
                          ? Colors.grey
                          : const Color(0xFFFF7A30),
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

            if (_isBooked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Not available at the moment.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
