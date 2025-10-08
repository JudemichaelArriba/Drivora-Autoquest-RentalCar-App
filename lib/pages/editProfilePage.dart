import 'dart:convert';
import 'dart:io';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivora_autoquest/components/my_numberTextfield.dart';
import 'package:drivora_autoquest/components/my_button.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
// import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final String uid;
  final String currentContact1;
  final String currentContact2;
  final String? currentLicenseFront;
  final String? currentLicenseBack;

  const EditProfilePage({
    super.key,
    required this.uid,
    required this.currentContact1,
    required this.currentContact2,
    this.currentLicenseFront,
    this.currentLicenseBack,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color accentColor = const Color(0xFFFF7A30);

  late TextEditingController contact1Controller;
  late TextEditingController contact2Controller;
  File? licenseFrontImage;
  File? licenseBackImage;

  bool isSaving = false;
  bool hasChanges = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    contact1Controller = TextEditingController(text: widget.currentContact1);
    contact2Controller = TextEditingController(text: widget.currentContact2);

    contact1Controller.addListener(_detectChanges);
    contact2Controller.addListener(_detectChanges);
  }

  void _detectChanges() {
    final changed =
        contact1Controller.text != widget.currentContact1 ||
        contact2Controller.text != widget.currentContact2 ||
        licenseFrontImage != null ||
        licenseBackImage != null;

    if (changed != hasChanges) {
      setState(() => hasChanges = changed);
    }
  }

  @override
  void dispose() {
    contact1Controller.removeListener(_detectChanges);
    contact2Controller.removeListener(_detectChanges);
    contact1Controller.dispose();
    contact2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront, bool fromCamera) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          licenseFrontImage = File(pickedFile.path);
        } else {
          licenseBackImage = File(pickedFile.path);
        }
        hasChanges = true;
      });
    }
  }

  Future<void> saveChanges() async {
    if (!hasChanges) return;

    if (contact1Controller.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 11-digit Contact 1."),
        ),
      );
      return;
    }

    if (contact2Controller.text.isNotEmpty &&
        contact2Controller.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 11-digit Contact 2."),
        ),
      );
      return;
    }

    if (licenseFrontImage == null && widget.currentLicenseFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please upload the front side of your driver’s license.",
          ),
        ),
      );
      return;
    }

    if (licenseBackImage == null && widget.currentLicenseBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please upload the back side of your driver’s license.",
          ),
        ),
      );
      return;
    }

    final confirm = await DialogHelper.showConfirmationDialog(
      context,
      message: "Do you want to save these changes?",
      confirmText: "Save",
      cancelText: "Cancel",
      confirmColor: const Color(0xFFFF7A30),
    );

    if (!confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile update canceled.")));
      return;
    }

    setState(() => isSaving = true);

    try {
      final userService = UserService(api: apiConnection);

      final success = await userService.updateUserProfile(
        uid: widget.uid,
        contactNumber1: contact1Controller.text.trim(),
        contactNumber2: contact2Controller.text.trim(),
        licenseFront: licenseFrontImage,
        licenseBack: licenseBackImage,
      );

      if (success && mounted) {
        DialogHelper.showSuccessDialog(
          context,
          "Profile updated successfully!",
          onContinue: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showErrorDialog(context, "Error updating profile: $e");
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: accentColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You can edit your contact numbers and update your driver’s license images.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            MyNumberTextField(
              controller: contact1Controller,
              label: "Contact Number 1",
              requiredLength: 11,
            ),
            const SizedBox(height: 20),
            MyNumberTextField(
              controller: contact2Controller,
              label: "Contact Number 2 (Optional)",
              requiredLength: 11,
            ),

            const SizedBox(height: 30),

            const Text(
              "Driver’s License Images",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF7A30),
              ),
            ),
            const SizedBox(height: 10),

            _buildImageUploadSection(
              "Front Side",
              true,
              widget.currentLicenseFront,
            ),
            const SizedBox(height: 20),
            _buildImageUploadSection(
              "Back Side",
              false,
              widget.currentLicenseBack,
            ),

            const SizedBox(height: 40),

            isSaving
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF7A30)),
                  )
                : Opacity(
                    opacity: hasChanges ? 1 : 0.5,
                    child: IgnorePointer(
                      ignoring: !hasChanges,
                      child: MyButton(
                        text: "Save Changes",
                        onPressed: saveChanges,
                        cornerRadius: 10,
                        buttonHeight: 50,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(
    String label,
    bool isFront,
    String? currentBase64,
  ) {
    final imageFile = isFront ? licenseFrontImage : licenseBackImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            image: imageFile != null
                ? DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                  )
                : currentBase64 != null && currentBase64.isNotEmpty
                ? DecorationImage(
                    image: MemoryImage(base64Decode(currentBase64)),
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
                          backgroundColor: accentColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () => _pickImage(isFront, false),
                        child: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF7A30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () => _pickImage(isFront, true),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Text(
                        "Camera",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF7A30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
