import 'package:drivora_autoquest/components/custom_card.dart';
import 'package:drivora_autoquest/components/categoryFilter.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:drivora_autoquest/models/car.dart';
import 'package:drivora_autoquest/pages/selectedCarPage.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Car> cars = [];
  List<Car> filteredCars = [];
  bool isLoading = true;
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final carService = CarService(api: apiConnection);
      final data = await carService.getCars();
      final carList = data.map<Car>((json) => Car.fromJson(json)).toList();

      setState(() {
        cars = carList;
        filteredCars = carList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "All") {
        filteredCars = cars;
      } else {
        filteredCars = cars
            .where((car) => car.carCategory == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    ImageProvider profileImage;
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      profileImage = NetworkImage(user.photoURL!);
    } else {
      profileImage = const AssetImage("assets/default_profile.png");
    }

    final categories = <String>{for (var car in cars) car.carCategory}.toList();

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
                          backgroundImage: profileImage,
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
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredCars.length,
                  itemBuilder: (context, index) {
                    final car = filteredCars[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CustomCard(
                        key: ValueKey(car.carId),
                        carId: car.carId,
                        title: car.carName,
                        imageUrl: car.imageBase64_1 != null
                            ? "data:image/png;base64,${car.imageBase64_1}"
                            : "https://via.placeholder.com/150",
                        rentPrice: "₱${car.rentPrice}",
                        favorites: car.favorites,
                        onButtonPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 380,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      SelectedCarPage(
                                        carId: car.carId,
                                        title: car.carName,
                                        imageUrl1: car.imageBase64_1 ?? "",
                                        imageUrl2: car.imageBase64_2 ?? "",
                                        imageUrl3: car.imageBase64_3 ?? "",
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
                                        favorites: car.favorites,
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
                        onFavoriteChanged: (isFav) {
                          setState(() {
                            car.favorites = isFav;
                          });
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
