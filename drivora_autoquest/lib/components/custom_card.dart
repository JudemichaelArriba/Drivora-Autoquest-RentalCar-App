import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
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

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _isFavorite = false;
  Uint8List? _decodedImage;

  bool get _isBase64 =>
      widget.imageUrl.isNotEmpty &&
      !widget.imageUrl.startsWith("http") &&
      !widget.imageUrl.startsWith("https");

  @override
  void didUpdateWidget(covariant CustomCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl) {
      _decodedImage = _isBase64 ? _decodeImage(widget.imageUrl) : null;
    }
  }

  @override
  void initState() {
    super.initState();
    _decodedImage = _isBase64 ? _decodeImage(widget.imageUrl) : null;
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
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
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
                    onPressed: widget.onButtonPressed,
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
