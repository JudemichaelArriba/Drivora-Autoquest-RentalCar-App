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
          _isFavorite = !_isFavorite;
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            Positioned(
              left: 16,
              top: 150,
              right: 16,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
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
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "RENT PRICE",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.rentPrice} / day",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: _isBooked
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFFF7A30), Color(0xFFFF5E00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: _isBooked ? Colors.grey : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isBooked
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFFFF7A30).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isBooked ? null : widget.onButtonPressed,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "BOOK NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isBooked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      "Currently Unavailable",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "This vehicle is booked",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
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
