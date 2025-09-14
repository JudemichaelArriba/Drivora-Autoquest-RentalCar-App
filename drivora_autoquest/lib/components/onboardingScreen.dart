import 'package:drivora_autoquest/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/images/carr1.png',
      'title': 'Welcome to Drivora ',
      'description': 'Find your perfect car easily with our app.',
    },
    {
      'image': 'lib/images/car2.png',
      'title': 'Book Instantly ',
      'description': 'Book any car in just a few taps.',
    },
    {
      'image': 'lib/images/car3.png',
      'title': 'Enjoy the Ride ',
      'description': 'Drive comfortably and safely with our service.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF5722)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Car image
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: currentPage == index ? 1.0 : 0.0,
                            child: Image.asset(
                              onboardingData[index]['image']!,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: currentPage == index
                                ? Offset.zero
                                : const Offset(0, 0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: currentPage == index ? 1.0 : 0.0,
                              child: Text(
                                onboardingData[index]['title']!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 700),
                            offset: currentPage == index
                                ? Offset.zero
                                : const Offset(0, 0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 700),
                              opacity: currentPage == index ? 1.0 : 0.0,
                              child: Text(
                                onboardingData[index]['description']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (currentPage == onboardingData.length - 1) {
                        Get.off(() => const LoginPage());
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(
                      currentPage == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Get.off(
                  () => const LoginPage(),
                  transition: Transition.fadeIn, // animation type
                  duration: const Duration(
                    milliseconds: 800,
                  ), // animation speed
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
