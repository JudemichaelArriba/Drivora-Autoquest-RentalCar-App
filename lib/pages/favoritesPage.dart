import 'package:drivora_autoquest/components/custom_card.dart';
import 'package:drivora_autoquest/components/categoryFilter.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:drivora_autoquest/models/car.dart';
import 'package:drivora_autoquest/pages/selectedCarPage.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/car_service.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Car> favoriteCars = [];
  List<Car> filteredCars = [];
  bool isLoading = true;
  String selectedCategory = "All";
  final TextEditingController searchController = TextEditingController();
  final Map<int, bool> removingMap = {};

  @override
  void initState() {
    super.initState();
    fetchFavoriteCars();
  }

  Future<void> fetchFavoriteCars() async {
    try {
      final carService = CarService(api: apiConnection);
      final data = await carService.getFavoriteCars();
      final carList = data.map<Car>((json) => Car.fromJson(json)).toList();

      setState(() {
        favoriteCars = carList;
        filteredCars = carList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorite cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterFavorites({String? category, String? query}) {
    String q = query?.toLowerCase() ?? '';
    String cat = category ?? selectedCategory;

    setState(() {
      selectedCategory = cat;
      filteredCars = favoriteCars.where((car) {
        final matchesCategory = cat == "All" || car.carCategory == cat;
        final matchesQuery = car.carName.toLowerCase().contains(q);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  void filterByCategory(String category) {
    filterFavorites(category: category, query: searchController.text);
  }

  void removeFavorite(Car car) {
    setState(() {
      removingMap[car.carId] = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        favoriteCars.removeWhere((c) => c.carId == car.carId);
        filteredCars.removeWhere((c) => c.carId == car.carId);
        removingMap.remove(car.carId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      for (var car in favoriteCars) car.carCategory,
    }.toList();

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
                          hintText: "Search favorites...",
                          onChanged: (text) {
                            filterFavorites(query: text);
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
              : filteredCars.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite cars yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredCars.length,
                  itemBuilder: (context, index) {
                    final car = filteredCars[index];
                    final isRemoving = removingMap[car.carId] ?? false;

                    return AnimatedOpacity(
                      key: ValueKey(car.carId),
                      opacity: isRemoving ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: isRemoving
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CustomCard(
                                  carId: car.carId,
                                  title: car.carName,
                                  status: car.status,
                                  imageUrl: car.imageBase64_1 != null
                                      ? "data:image/png;base64,${car.imageBase64_1}"
                                      : "https://via.placeholder.com/150",
                                  rentPrice: "₱${car.rentPrice}",
                                  favorites: car.favorites,
                                  onButtonPressed: () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 380,
                                        ),
                                        reverseTransitionDuration:
                                            const Duration(milliseconds: 200),
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => SelectedCarPage(
                                              carId: car.carId,
                                              title: car.carName,
                                              imageUrl1:
                                                  car.imageBase64_1 ?? "",
                                              imageUrl2:
                                                  car.imageBase64_2 ?? "",
                                              imageUrl3:
                                                  car.imageBase64_3 ?? "",
                                              rentPrice: "${car.rentPrice}",
                                              carBrand: car.carBrand.isNotEmpty
                                                  ? car.carBrand
                                                  : "Unknown brand",
                                              carDescription:
                                                  car.carDescription.isNotEmpty
                                                  ? car.carDescription
                                                  : "No description available",
                                              carCategory:
                                                  car.carCategory.isNotEmpty
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
                                                      reverseCurve:
                                                          Curves.easeIn,
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
                                                      reverseCurve:
                                                          Curves.easeIn,
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

                                    if (result == false) {
                                      removeFavorite(car);
                                    }
                                  },
                                  onFavoriteChanged: (isFav) {
                                    if (!isFav) {
                                      removeFavorite(car);
                                    } else {
                                      setState(() {
                                        car.favorites = isFav;
                                      });
                                    }
                                  },
                                ),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
