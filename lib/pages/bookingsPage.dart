import 'package:drivora_autoquest/components/booking_card.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:drivora_autoquest/components/categoryFilter.dart';

import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';

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
      final carService = CarService(api: apiConnection);
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
              : filteredBookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return BookingCard(
                      bookingId: booking['bookingId']?.toString() ?? 'N/A',

                      startDate: booking['start_date']?.toString() ?? '-',
                      endDate: booking['end_date']?.toString() ?? '-',
                      totalPrice:
                          double.tryParse(
                            booking['total_price']?.toString() ?? '0',
                          ) ??
                          0.0,
                      status: booking['status']?.toString() ?? 'Unknown',
                      onDetailsPressed: () {},
                      onCancelPressed: booking['status'] == "Pending"
                          ? () {}
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
