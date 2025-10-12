import 'dart:convert';
import 'dart:typed_data';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailPage extends StatefulWidget {
  final String bookingId;
  final int carId;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;

  const BookingDetailPage({
    super.key,
    required this.bookingId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Uint8List?> _carImages = [null, null, null];
  bool _loadingImages = true;

  @override
  void initState() {
    super.initState();
    _fetchCarImages();
  }

  Future<void> _fetchCarImages() async {
    try {
      final carService = CarService(api: apiConnection);
      final car = await carService.getCarById(widget.carId);

      setState(() {
        _carImages = [
          _decodeBase64(car.imageBase64_1),
          _decodeBase64(car.imageBase64_2),
          _decodeBase64(car.imageBase64_3),
        ];
      });
    } catch (e) {
      print("Failed to load car images: $e");
    } finally {
      setState(() {
        _loadingImages = false;
      });
    }
  }

  Uint8List? _decodeBase64(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final clean = data.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      return base64Decode(clean);
    } catch (e) {
      return null;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      case "completed":
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('MMMM dd, yyyy').format(dt);
    } catch (_) {
      return dateTimeStr;
    }
  }

  String formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  Widget _buildInfoCard(String label, String value, {IconData? icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.orange, size: 28),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildImage(Uint8List? decoded) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          decoded != null
              ? Image.memory(decoded, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.orange
                : Colors.orange.shade200,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Booking Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFFF7A30),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: _loadingImages
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : Stack(
                        children: [
                          PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            children: _carImages.map(_buildImage).toList(),
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.bookingId,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                "Start Date",
                "${formatDate(widget.startDate)} • ${formatTime(widget.startDate)}",
                icon: Icons.calendar_today,
              ),
              _buildInfoCard(
                "End Date",
                "${formatDate(widget.endDate)} • ${formatTime(widget.endDate)}",
                icon: Icons.access_time,
              ),
              _buildInfoCard(
                "Total Price",
                "₱${widget.totalPrice.toStringAsFixed(2)}",
                icon: Icons.attach_money,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
