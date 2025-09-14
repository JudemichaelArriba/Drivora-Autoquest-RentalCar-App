import 'package:drivora_autoquest/components/custom_card.dart';
import 'package:drivora_autoquest/pages/selectedCarPage.dart';
import 'package:flutter/material.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivora_autoquest/models/car.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:drivora_autoquest/services/api_connection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Car> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final carService = CarService(api: apiConnection);
      final data = await carService.getCars();

      setState(() {
        cars = data.map<Car>((json) => Car.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String firstName = "";
    if (user != null && user.displayName != null) {
      firstName = user.displayName!.split(" ").first;
    }

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
                        top: 47,
                        right: 20,
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              FirebaseAuth.instance.currentUser?.photoURL !=
                                  null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!,
                                )
                              : const AssetImage("assets/default_profile.png")
                                    as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 45,
                        left: -5,
                        right: 60,
                        child: Widgetsearchbar(
                          height: 50,
                          borderRadius: 15,
                          width: 130,
                          hintText: "Search for cars...",
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
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CustomCard(
                        title: car.carName,
                        imageUrl: car.imageBase64 != null
                            ? "data:image/png;base64,${car.imageBase64}"
                            : "https://via.placeholder.com/150",
                        rentPrice: "\$${car.rentPrice}",
                        onButtonPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 450,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      SelectedCarPage(
                                        title: car.carName,
                                        imageUrl: car.imageBase64 ?? "",
                                        rentPrice: "${car.rentPrice}",
                                        carBrand: car.carBrand.isNotEmpty
                                            ? car.carBrand
                                            : "Unknown brand",
                                        carDescription:
                                            car.carDescription.isNotEmpty
                                            ? car.carDescription
                                            : "No description available",
                                        carCategory: car.carCategory.isNotEmpty
                                            ? car.carCategory
                                            : "Uncategorized",
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final scaleAnimation =
                                        Tween<double>(
                                          begin: 0.8,
                                          end: 1.0,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                            reverseCurve: Curves.easeIn,
                                          ),
                                        );
                                    final fadeAnimation =
                                        Tween<double>(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                            reverseCurve: Curves.easeIn,
                                          ),
                                        );

                                    return ScaleTransition(
                                      scale: scaleAnimation,
                                      child: FadeTransition(
                                        opacity: fadeAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
