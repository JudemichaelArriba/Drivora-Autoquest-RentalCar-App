import 'package:drivora_autoquest/components/custom_card.dart';
import 'package:drivora_autoquest/pages/selectedCarPage.dart';
import 'package:flutter/material.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String firstName = "";
    if (user != null && user.displayName != null) {
      firstName = user.displayName!.split(" ").first;
    }

    final List<Map<String, String>> cars = [
      {
        "title": "Nissan Sedan",
        "imageUrl":
            "https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
        "price": "\$50",
      },
      {
        "title": "Luxury Supercar",
        "imageUrl": "https://photogallery.indiatimes.com/photo/80387914.cms",
        "price": "\$120",
      },
      {
        "title": "Nissan Choice",
        "imageUrl":
            "https://www.nissan.in/content/dam/Nissan/in/Nissan-intelligent-choice/nic-banner.jpg",
        "price": "\$70",
      },
    ];

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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomCard(
                  title: car["title"]!,
                  imageUrl: car["imageUrl"]!,
                  price: car["price"]!,
                  onButtonPressed: () {
                    Get.to(
                      SelectedCarPage(
                        title: car["title"]!,
                        imageUrl: car["imageUrl"]!,
                        price: car["price"]!,
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
