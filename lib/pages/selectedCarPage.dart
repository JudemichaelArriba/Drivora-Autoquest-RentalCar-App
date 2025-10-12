import 'dart:convert';
import 'dart:typed_data';
import 'package:drivora_autoquest/components/my_button.dart';
import 'package:drivora_autoquest/components/rentalRulesDialog.dart';
import 'package:drivora_autoquest/pages/bookPage.dart';
import 'package:drivora_autoquest/pages/credentialPage.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _SelectedCarPageState extends State<SelectedCarPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late bool _isFavorite;
  bool _agreedToRules = false;
  late List<Uint8List?> _decodedImages;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.favorites;

    _decodedImages = [
      _decodeBase64(widget.imageUrl1),
      _decodeBase64(widget.imageUrl2),
      _decodeBase64(widget.imageUrl3),
    ];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
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
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
      child: decoded != null
          ? Image.memory(
              decoded,
              fit: BoxFit.cover,
              width: double.infinity,
              gaplessPlayback: true,
            )
          : Container(
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.grey.shade600,
              ),
            ),
    );
  }

  Widget _buildDotIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? Colors.white : Colors.white54,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
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
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to add favorites"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      bool success;
      if (_isFavorite) {
        success = await carService.markAsFavorite(uid, widget.carId);
      } else {
        success = await carService.unmarkAsFavorite(uid, widget.carId);
      }

      if (!success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to update favorite"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update favorite: $e"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _popPage() {
    Navigator.pop(context, _isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _popPage();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(opacity: _fadeAnimation, child: child);
          },
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _popPage,
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.red : Colors.white,
                            size: 24,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildImage(_decodedImages[0]),
                        _buildImage(_decodedImages[1]),
                        _buildImage(_decodedImages[2]),
                      ],
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildDotIndicator(),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Colors.black87,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.carBrand,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7A30), Color(0xFFFF5E00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₱${widget.rentPrice}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "/day",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              icon: Icons.category_rounded,
                              title: "Category",
                              value: widget.carCategory,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.description_rounded,
                              title: "Description",
                              value: widget.carDescription,
                              isDescription: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildModernCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF7A30),
                                    Color(0xFFFF5E00),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rental Guidelines',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Important rules and policies',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showRentalRulesDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: MyButton(
                        text: "Book Now",
                        cornerRadius: 16,
                        buttonWidth: double.infinity,
                        buttonHeight: 56,
                        onPressed: () async {
                          if (!_agreedToRules) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Please read and accept the Rental Rules first.",
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          final User? user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Please log in to continue",
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          try {
                            String uid = user.uid;
                            String status = await checkUserStatus(uid);

                            if (status ==
                                "User exists and information is complete") {
                              if (user != null) {
                                print(user.uid);
                                print(widget.carId);
                                Get.to(
                                  Bookpage(
                                    carPrice: widget.rentPrice,
                                    uid: user.uid,
                                    carId: widget.carId,
                                  ),
                                );
                              }
                            } else if (status ==
                                    "User exists but information is incomplete" ||
                                status == "User does not exist") {
                              Get.to(
                                CredentialPage(
                                  carPrice: widget.rentPrice,
                                  uid: user.uid,
                                  carId: widget.carId,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Unexpected status: $status"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Failed to check user status: $e",
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isDescription = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7A30).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF7A30), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDescription ? 15 : 16,
                  fontWeight: isDescription ? FontWeight.w500 : FontWeight.w600,
                  color: Colors.black87,
                  height: isDescription ? 1.4 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
