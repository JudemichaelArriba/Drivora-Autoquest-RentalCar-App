import 'dart:convert';
import 'dart:io';
import 'package:drivora_autoquest/components/my_numberTextfield.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class CredentialPage extends StatefulWidget {
  const CredentialPage({super.key});

  @override
  State<CredentialPage> createState() => _CredentialPageState();
}

class _CredentialPageState extends State<CredentialPage> {
  final TextEditingController _contact1Controller = TextEditingController();
  final TextEditingController _contact2Controller = TextEditingController();

  File? _frontImage;
  File? _backImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contact1Controller.addListener(_onFieldsChanged);
    _contact2Controller.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _contact1Controller.dispose();
    _contact2Controller.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _contact1Controller.text.isNotEmpty &&
        _contact2Controller.text.isNotEmpty &&
        _frontImage != null &&
        _backImage != null;
  }

  void _onFieldsChanged() {
    setState(() {});
  }

  Future<void> _pickImage(bool isFront, bool fromCamera) async {
    if (fromCamera) {
      bool granted = await Permission.camera.request().isGranted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    }

    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Credentials", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(
          context,
        ).copyWith(overscroll: false, scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepCard(
                stepNumber: 1,
                stepTitle: "Contact Numbers",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Enter at least two contact numbers"),
                    const SizedBox(height: 12),
                    MyNumberTextField(
                      controller: _contact1Controller,
                      label: "Contact Number 1",
                    ),
                    const SizedBox(height: 12),
                    MyNumberTextField(
                      controller: _contact2Controller,
                      label: "Contact Number 2",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStepCard(
                stepNumber: 2,
                stepTitle: "Upload Driver's License",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Front Side"),
                    const SizedBox(height: 10),
                    _buildUploadContainer(
                      imageFile: _frontImage,
                      onUpload: () => _pickImage(true, false),
                      onCamera: () => _pickImage(true, true),
                    ),
                    const SizedBox(height: 20),
                    const Text("Back Side"),
                    const SizedBox(height: 10),
                    _buildUploadContainer(
                      imageFile: _backImage,
                      onUpload: () => _pickImage(false, false),
                      onCamera: () => _pickImage(false, true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? const Color(0xFFFF7A30)
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 130,
                      vertical: 14,
                    ),
                  ),
                  onPressed: _isFormValid
                      ? () async {
                          final User? user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User not logged in"),
                              ),
                            );
                            return;
                          }

                          if (_frontImage == null || _backImage == null) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            var uri = Uri.parse(
                              '${apiConnection.baseUrl}/add_userCredentials.php',
                            );
                            var request = http.MultipartRequest('POST', uri);

                            request.fields['uid'] = user.uid;
                            request.fields['email'] = user.email!;
                            request.fields['contact_number1'] =
                                _contact1Controller.text.trim();
                            request.fields['contact_number2'] =
                                _contact2Controller.text.trim();

                            request.files.add(
                              await http.MultipartFile.fromPath(
                                'drivers_license_front',
                                _frontImage!.path,
                              ),
                            );
                            request.files.add(
                              await http.MultipartFile.fromPath(
                                'drivers_license_back',
                                _backImage!.path,
                              ),
                            );

                            var response = await request.send();
                            var responseBody = await response.stream
                                .bytesToString();

                            Navigator.pop(context);

                            var jsonResponse = jsonDecode(responseBody);
                            if (jsonResponse['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("User added successfully"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed: ${jsonResponse['error']}",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            print("Failed to add user: $e");
                          }
                        }
                      : null,
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String stepTitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFFF7A30),
                child: Text(
                  "$stepNumber",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildUploadContainer({
    required File? imageFile,
    required VoidCallback onUpload,
    required VoidCallback onCamera,
  }) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        image: imageFile != null
            ? DecorationImage(
                image: FileImage(imageFile),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: onUpload,
                    child: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const Text(
                    "Upload",
                    style: TextStyle(fontSize: 12, color: Color(0xFFFF7A30)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: onCamera,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const Text(
                    "Camera",
                    style: TextStyle(fontSize: 12, color: Color(0xFFFF7A30)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
