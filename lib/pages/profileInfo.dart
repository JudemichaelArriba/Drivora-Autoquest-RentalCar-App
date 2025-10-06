import 'dart:convert';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatefulWidget {
  final String uid;
  final String? photoUrl;

  const ProfileInfo({super.key, required this.uid, this.photoUrl});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  late Future<Map<String, dynamic>> _userData;
  late UserService userService;
  final Color accentColor = const Color(0xFFFF7A30);

  @override
  void initState() {
    super.initState();
    userService = UserService(api: apiConnection);
    _userData = userService.getUserById(widget.uid);
  }

  String cleanBase64(String base64String) {
    if (base64String.startsWith('data:image')) {
      final commaIndex = base64String.indexOf(',');
      return base64String.substring(commaIndex + 1);
    }
    return base64String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile Information"),
        centerTitle: true,
        backgroundColor: accentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data found"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.8), accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: widget.photoUrl != null
                            ? NetworkImage(widget.photoUrl!)
                            : null,
                        child: widget.photoUrl == null
                            ? Icon(Icons.person, size: 60, color: accentColor)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['email'] ?? 'No Email',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          buildInfoRow(Icons.email, "Email", user['email']),
                          const SizedBox(height: 12),
                          buildInfoRow(
                            Icons.phone,
                            "Contact 1",
                            user['contact_number1'],
                          ),
                          const SizedBox(height: 12),
                          buildInfoRow(
                            Icons.phone_android,
                            "Contact 2",
                            user['contact_number2'],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Driver's License",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          licenseImage(user['drivers_license_front'], "Front"),
                          const SizedBox(height: 20),
                          licenseImage(user['drivers_license_back'], "Back"),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String? value) {
    return Row(
      children: [
        Icon(icon, color: accentColor),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget licenseImage(String? base64Image, String label) {
    Widget imageWidget;

    if (base64Image == null || base64Image.isEmpty) {
      imageWidget = _placeholderImage();
    } else {
      try {
        final bytes = base64Decode(cleanBase64(base64Image));
        imageWidget = GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        imageWidget = _errorImage();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        imageWidget,
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 50,
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.error, color: Colors.red, size: 50),
    );
  }
}
