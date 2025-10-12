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

      billList.sort((a, b) {
        if (a.paymentStatus.toLowerCase() == 'cancelled' &&
            b.paymentStatus.toLowerCase() != 'cancelled')
          return 1;
        if (b.paymentStatus.toLowerCase() == 'cancelled' &&
            a.paymentStatus.toLowerCase() != 'cancelled')
          return -1;
        return b.issuedAt.compareTo(a.issuedAt);
      });

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

    final filtered = bills.where((bill) {
      final matchesCategory = cat == "All" || bill.paymentStatus == cat;
      final matchesQuery =
          bill.billId.toString().toLowerCase().contains(q) ||
          bill.bookingId.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    filtered.sort((a, b) {
      if (a.paymentStatus.toLowerCase() == 'cancelled' &&
          b.paymentStatus.toLowerCase() != 'cancelled')
        return 1;
      if (b.paymentStatus.toLowerCase() == 'cancelled' &&
          a.paymentStatus.toLowerCase() != 'cancelled')
        return -1;
      return b.issuedAt.compareTo(a.issuedAt);
    });

    setState(() {
      selectedCategory = cat;
      filteredBills = filtered;
    });
  }

  void filterByCategory(String category) {
    filterBills(category: category, query: searchController.text);
  }

  double get totalAmount {
    return bills
        .where((bill) => bill.paymentStatus.toLowerCase() == 'unpaid')
        .fold(0, (sum, bill) => sum + bill.amount);
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 33),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFF7A30).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF7A30,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: Color(0xFFFF7A30),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\₱${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFF7A30),
                                    ),
                                  ),
                                  const Text(
                                    'Total Bills',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      filteredBills.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                'No bills yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                120,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
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
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
