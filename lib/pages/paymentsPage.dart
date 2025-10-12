import 'package:drivora_autoquest/components/BillCard.dart';
import 'package:drivora_autoquest/components/categoryFilter.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:drivora_autoquest/models/Bill.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController searchController = TextEditingController();
  List<Bill> bills = [];
  List<Bill> filteredBills = [];
  bool isLoading = true;
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      setState(() => isLoading = false);
      return;
    }

    try {
      final userService = UserService(api: apiConnection);
      final data = await userService.getUserBills(uid);
      final billList = (data['bills'] as List<Bill>).toList();

      setState(() {
        bills = billList;
        filteredBills = billList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching bills: $e')));
    }
  }

  void filterBills({String? category, String? query}) {
    final q = query?.toLowerCase() ?? '';
    final cat = category ?? selectedCategory;

    setState(() {
      selectedCategory = cat;
      filteredBills = bills.where((bill) {
        final matchesCategory = cat == "All" || bill.paymentStatus == cat;
        final matchesQuery =
            bill.billId.toString().toLowerCase().contains(q) ||
            bill.bookingId.toLowerCase().contains(q);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  void filterByCategory(String category) {
    filterBills(category: category, query: searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      for (var bill in bills) bill.paymentStatus,
    }.toList();
    categories.sort();

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
                          hintText: "Search bills...",
                          onChanged: (text) => filterBills(query: text),
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
              : filteredBills.isEmpty
              ? const Center(
                  child: Text(
                    'No bills yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    return BillCard(
                      key: ValueKey(bill.billId),
                      billId: bill.billId.toString(),
                      bookingId: bill.bookingId,
                      carId: bill.carId,
                      amount: bill.amount,
                      paymentStatus: bill.paymentStatus,
                      issuedAt: bill.issuedAt.toIso8601String(),
                      updatedAt: bill.updatedAt.toIso8601String(),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
