import 'dart:convert';
import 'package:drivora_autoquest/components/dateChooser.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Bookpage extends StatefulWidget {
  final String carPrice;

  const Bookpage({super.key, required this.carPrice});

  @override
  State<Bookpage> createState() => _BookpageState();
}

class _BookpageState extends State<Bookpage> {
  DateTime? _pickupDate;
  DateTime? _returnDate;
  double get _carPricePerDay {
    final numericString = widget.carPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  int get _rentalDays {
    if (_pickupDate != null && _returnDate != null) {
      final pickup = DateTime(
        _pickupDate!.year,
        _pickupDate!.month,
        _pickupDate!.day,
      );
      final ret = DateTime(
        _returnDate!.year,
        _returnDate!.month,
        _returnDate!.day,
      );
      return ret.difference(pickup).inDays + 1;
    }
    return 0;
  }

  double get _totalCost => _rentalDays * _carPricePerDay;

  bool get _isFormValid {
    return _pickupDate != null && _returnDate != null && _rentalDays > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Booking", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(overscroll: false, scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepCard(
                stepNumber: 1,
                stepTitle: "Date Info",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pick up date"),
                    const SizedBox(height: 8),
                    DateTimeChooser(
                      selectedDateTime: _pickupDate,
                      onDateTimeSelected: (dateTime) {
                        setState(() {
                          _pickupDate = dateTime;

                          if (_returnDate != null &&
                              _returnDate!.isBefore(_pickupDate!)) {
                            _returnDate = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Return date"),
                    const SizedBox(height: 8),
                    DateTimeChooser(
                      selectedDateTime: _returnDate,
                      onDateTimeSelected: (dateTime) {
                        setState(() {
                          _returnDate = dateTime;
                        });
                      },
                      firstDate: _pickupDate?.add(const Duration(minutes: 1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStepCard(
                stepNumber: 2,
                stepTitle: "Car Price",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Rental Price",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "₱${widget.carPrice}/day",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7A30),
                          ),
                        ),
                      ],
                    ),
                    if (_isFormValid) ...[
                      const SizedBox(height: 16),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 4,
                        endIndent: 4,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total ($_rentalDays days)",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "₱$_totalCost",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid
                ? const Color(0xFFFF7A30)
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _isFormValid
              ? () async {
                  final User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Booking submitted! Total: ₱$_totalCost for $_rentalDays days",
                      ),
                    ),
                  );
                }
              : null,
          child: const Text(
            "Confirm Booking",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String stepTitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFFF7A30),
                child: Text(
                  "$stepNumber",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
