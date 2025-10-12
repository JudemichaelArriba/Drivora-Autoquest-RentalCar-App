import 'dart:convert';
import 'dart:typed_data';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailPage extends StatefulWidget {
  final String bookingId;
  final int carId; // <-- Add carId
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;

  const BookingDetailPage({
    super.key,
    required this.bookingId,
    required this.carId, // <-- Add this
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Uint8List? _carImage;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
    _fetchCarImage();
  }

  Future<void> _fetchCarImage() async {
    try {
      final carService = CarService(api: apiConnection);
      final cars = await carService.getCars(""); // Or a dedicated getCarById()
      final car = cars.firstWhere(
        (c) => c['carId'].toString() == widget.carId.toString(),
      );

      if (car['image_data1'] != null) {
        setState(() {
          _carImage = base64Decode(
            car['image_data1'].replaceFirst(
              RegExp(r'data:image/[^;]+;base64,'),
              '',
            ),
          );
        });
      }
    } catch (e) {
      print("Failed to load car image: $e");
    } finally {
      setState(() {
        _loadingImage = false;
      });
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

  Widget buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: Colors.orange, size: 20),
          if (icon != null) const SizedBox(width: 8),
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
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Car Image
              Center(
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade200,
                  ),
                  child: _loadingImage
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      : _carImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(_carImage!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.grey,
                            size: 80,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 🧾 Booking ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Booking #${widget.bookingId}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),

              const SizedBox(height: 16),
              buildInfoRow(
                "Start Date",
                "${formatDate(widget.startDate)} • ${formatTime(widget.startDate)}",
                icon: Icons.calendar_today,
              ),
              buildInfoRow(
                "End Date",
                "${formatDate(widget.endDate)} • ${formatTime(widget.endDate)}",
                icon: Icons.access_time,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              buildInfoRow(
                "Total Price",
                "₱${widget.totalPrice.toStringAsFixed(2)}",
                icon: Icons.attach_money,
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
