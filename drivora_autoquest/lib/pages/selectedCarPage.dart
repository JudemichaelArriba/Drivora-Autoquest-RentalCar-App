import 'dart:convert';
import 'dart:typed_data';
import 'package:drivora_autoquest/components/rentalRulesDialog.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:flutter/material.dart';

class SelectedCarPage extends StatefulWidget {
  final int carId;
  final String title;
  final String imageUrl1;
  final String imageUrl2;
  final String imageUrl3;
  final String rentPrice;
  final String carBrand;
  final String carDescription;
  final String carCategory;
  final bool favorites;

  const SelectedCarPage({
    super.key,
    required this.carId,
    required this.title,
    this.imageUrl1 = '',
    this.imageUrl2 = '',
    this.imageUrl3 = '',
    this.rentPrice = '0',
    this.carBrand = 'Unknown brand',
    this.carDescription = 'No description available',
    this.carCategory = 'Uncategorized',
    this.favorites = false,
  });

  @override
  State<SelectedCarPage> createState() => _SelectedCarPageState();
}

class _SelectedCarPageState extends State<SelectedCarPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late bool _isFavorite;
  bool _agreedToRules = false;
  late List<Uint8List?> _decodedImages;

  @override
  void initState() {
    super.initState();
    // Initialize favorite from the passed value
    _isFavorite = widget.favorites;

    // Decode images here (keeps the UI identical)
    _decodedImages = [
      _decodeBase64(widget.imageUrl1),
      _decodeBase64(widget.imageUrl2),
      _decodeBase64(widget.imageUrl3),
    ];
  }

  Uint8List? _decodeBase64(String data) {
    if (data.isEmpty) return null;
    try {
      final clean = data.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      return base64Decode(clean);
    } catch (e) {
      return null;
    }
  }

  Widget _buildImage(Uint8List? decoded) {
    if (decoded != null) {
      return Image.memory(
        decoded,
        fit: BoxFit.cover,
        width: double.infinity,
        gaplessPlayback: true,
      );
    }
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.directions_car, size: 64, color: Colors.white70),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          width: _currentPage == index ? 10 : 6,
          height: _currentPage == index ? 10 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : Colors.white54,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _showRentalRulesDialog() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => const RentalRulesDialog(),
    );

    if (agreed == true) {
      setState(() {
        _agreedToRules = true;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final carService = CarService(api: apiConnection);

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      bool success;
      if (_isFavorite) {
        success = await carService.markAsFavorite(widget.carId);
      } else {
        success = await carService.unmarkAsFavorite(widget.carId);
      }

      if (!success) {
        // revert if not success
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update favorite.")),
        );
      }
    } catch (e) {
      // revert and show error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update favorite: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),

                onPressed: () => Navigator.pop(context, _isFavorite),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (_currentPage != index) {
                        setState(() {
                          _currentPage = index;
                        });
                      }
                    },
                    children: [
                      _buildImage(_decodedImages[0]),
                      _buildImage(_decodedImages[1]),
                      _buildImage(_decodedImages[2]),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: _buildDotIndicator(),
                  ),
                ],
              ),
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₱${widget.rentPrice}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF7A30),
                                ),
                              ),
                              const Text(
                                "/day",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 20),
                      _buildDetailTile(
                        icon: Icons.directions_car_filled,
                        label: "Brand",
                        value: widget.carBrand,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailTile(
                        icon: Icons.category,
                        label: "Category",
                        value: widget.carCategory,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailTile(
                        icon: Icons.description,
                        label: "Description",
                        value: widget.carDescription,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7A30),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.car_rental,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drivora Autoquest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showRentalRulesDialog,
                              child: const Text(
                                'Rental rules >',
                                style: TextStyle(
                                  color: Colors.blue,
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!_agreedToRules) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please read and accept the Rental Rules first.",
                              ),
                            ),
                          );
                          return;
                        }
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF7A30), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
