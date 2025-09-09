import 'package:flutter/material.dart';
import 'package:drivora_autoquest/components/widgetSearchBar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 225,
          child: Stack(
            children: [
              Material(
                elevation: 4,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7A30),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 110,
                        left: 0,
                        right: 155,
                        child: Center(
                          child: Text(
                            'Choose a Car',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        left: 5,
                        right: 5,
                        child: Widgetsearchbar(
                          height: 50,
                          borderRadius: 15,
                          width: double.infinity,
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
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: const Center(
              child: Text(
                'Mga cars sa ubos Kakapooyy 😭',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
