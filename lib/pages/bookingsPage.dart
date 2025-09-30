import 'package:drivora_autoquest/components/booking_card.dart';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:drivora_autoquest/components/categoryFilter.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> bookings = [];
  List<dynamic> filteredBookings = [];
  bool isLoading = true;
  String selectedCategory = "All";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    try {
      final data = await UserService(api: apiConnection).getActiveBookings(uid);
      setState(() {
        bookings = data;
        filteredBookings = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterBookings({String? category, String? query}) {
    String q = query?.toLowerCase() ?? '';
    String cat = category ?? selectedCategory;

    setState(() {
      selectedCategory = cat;
      filteredBookings = bookings.where((b) {
        final matchesCategory = cat == "All" || b['status'] == cat;
        final matchesQuery = b['car_title'].toString().toLowerCase().contains(
          q,
        );
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  void filterByCategory(String category) {
    filterBookings(category: category, query: searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{for (var b in bookings) b['status']}.toList();

    final upcomingCount = bookings
        .where((b) => b['status']?.toString().toLowerCase() == 'pending')
        .length;
    final doneCount = bookings
        .where((b) => b['status']?.toString().toLowerCase() == 'completed')
        .length;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              Material(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFFF7A30)),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 45,
                        left: 0,
                        right: 0,
                        child: Widgetsearchbar(
                          controller: searchController,
                          hintText: "Search bookings...",
                          onChanged: (text) {
                            filterBookings(query: text);
                          },
                          height: 50,
                          borderRadius: 15,
                          width: 130,
                        ),
                      ),
                      if (!isLoading)
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: CategoryFilter(
                            categories: categories,
                            selectedCategory: selectedCategory,
                            onCategorySelected: filterByCategory,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF7A30)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 33),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSummaryBox(
                                'Upcoming',
                                upcomingCount,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryBox(
                                'Done',
                                doneCount,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return BookingCard(
                            bookingId:
                                booking['bookingId']?.toString() ?? 'N/A',
                            startDate: booking['start_date']?.toString() ?? '-',
                            endDate: booking['end_date']?.toString() ?? '-',
                            totalPrice:
                                double.tryParse(
                                  booking['total_price']?.toString() ?? '0',
                                ) ??
                                0.0,
                            status: booking['status']?.toString() ?? 'Unknown',
                            onDetailsPressed: () {},
                            onCancelPressed:
                                booking['status']?.toString().toLowerCase() ==
                                    "pending"
                                ? () async {
                                    final confirmed =
                                        await DialogHelper.showLogoutConfirmation(
                                          context,
                                        );

                                    if (confirmed) {
                                      try {
                                        final carService = CarService(
                                          api: apiConnection,
                                        );
                                        final message = await carService
                                            .cancelBooking(
                                              booking['bookingId'].toString(),
                                            );

                                        DialogHelper.showSuccessDialog(
                                          context,
                                          message,
                                          onContinue: () {
                                            fetchBookings();
                                          },
                                        );
                                      } catch (e) {
                                        DialogHelper.showErrorDialog(
                                          context,
                                          "Error: $e",
                                        );
                                      }
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
