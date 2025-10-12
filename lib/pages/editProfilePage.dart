import 'dart:convert';
import 'dart:io';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivora_autoquest/components/my_numberTextfield.dart';

import 'package:drivora_autoquest/services/api_connection.dart';

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
        SnackBar(
          content: const Text("Please enter a valid 11-digit Contact 1."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (contact2Controller.text.isNotEmpty &&
        contact2Controller.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid 11-digit Contact 2."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (licenseFrontImage == null && widget.currentLicenseFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please upload the front side of your driver's license.",
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (licenseBackImage == null && widget.currentLicenseBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please upload the back side of your driver's license.",
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile update canceled."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: accentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You can update your contact information and driver's license",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  MyNumberTextField(
                    controller: contact1Controller,
                    label: "Primary Contact Number",
                    requiredLength: 11,
                  ),
                  const SizedBox(height: 16),
                  MyNumberTextField(
                    controller: contact2Controller,
                    label: "Secondary Contact Number (Optional)",
                    requiredLength: 11,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Driver's License",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildImageUploadSection(
                    "Front Side",
                    true,
                    widget.currentLicenseFront,
                  ),
                  const SizedBox(height: 24),
                  _buildImageUploadSection(
                    "Back Side",
                    false,
                    widget.currentLicenseBack,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: hasChanges
                    ? LinearGradient(
                        colors: [accentColor, const Color(0xFFFF9A30)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: hasChanges
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: hasChanges && !isSaving ? saveChanges : null,
                  child: Stack(
                    children: [
                      Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
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
