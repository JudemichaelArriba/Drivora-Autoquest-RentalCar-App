import 'dart:convert';
import 'dart:typed_data';
import 'package:drivora_autoquest/components/dialog_helper.dart';
import 'package:drivora_autoquest/pages/forgotPasswordPage.dart';
import 'package:drivora_autoquest/pages/profileInfo.dart';
import 'package:drivora_autoquest/services/api_connection.dart';
import 'package:drivora_autoquest/services/auth_service.dart';
import 'package:drivora_autoquest/services/user_service.dart';
import 'package:drivora_autoquest/models/user.dart' as MyUser;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fbAuth.User? firebaseUser = fbAuth.FirebaseAuth.instance.currentUser;
    bool isGoogleUser = false;
    String? photoUrl;
    String displayName = 'User';
    String email = 'example@mail.com';
    String? uid = firebaseUser?.uid;

    Widget buildProfilePicture(Uint8List? bytes, String? url) {
      if (url != null) {
        return CircleAvatar(radius: 60, backgroundImage: NetworkImage(url));
      } else if (bytes != null) {
        return CircleAvatar(radius: 60, backgroundImage: MemoryImage(bytes));
      } else {
        return CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFFFF7A30).withOpacity(0.1),
          child: const Icon(Icons.person, size: 50, color: Color(0xFFFF7A30)),
        );
      }
    }

    return FutureBuilder<MyUser.User?>(
      future: uid != null
          ? UserService(api: apiConnection).getUserById(uid)
          : Future.value(null),
      builder: (context, snapshot) {
        MyUser.User? dbUser = snapshot.data;

        if (firebaseUser != null) {
          for (var provider in firebaseUser.providerData) {
            if (provider.providerId == 'google.com') {
              isGoogleUser = true;
              photoUrl = provider.photoURL;
            }
          }
        }

        if (!isGoogleUser && dbUser != null) {
          displayName =
              ((dbUser.firstName ?? '') + ' ' + (dbUser.lastName ?? '')).trim();
          email = dbUser.email ?? 'example@mail.com';
        } else if (firebaseUser != null) {
          displayName = firebaseUser.displayName ?? 'User';
          email = firebaseUser.email ?? 'example@mail.com';
        }

        Uint8List? profileBytes;
        if (!isGoogleUser && dbUser?.profilePic != null) {
          try {
            profileBytes = base64Decode(dbUser!.profilePic!);
          } catch (_) {
            profileBytes = null;
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black54),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF7A30).withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: buildProfilePicture(profileBytes, photoUrl),
                ),
                const SizedBox(height: 24),
                Text(
                  displayName.isEmpty ? 'User' : displayName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (email.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF7A30),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                _buildModernCard(
                  children: [
                    _buildModernListTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Manage your personal details',
                      onTap: () {
                        if (uid != null) {
                          Get.to(
                            () => ProfileInfo(uid: uid, photoUrl: photoUrl),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'User ID not found. Please re-login.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    if (!isGoogleUser) ...[
                      const Divider(height: 1, indent: 56),
                      _buildModernListTile(
                        icon: Icons.lock_reset_rounded,
                        title: 'Reset Password',
                        subtitle: 'Change your password',
                        onTap: () async {
                          if (email.isNotEmpty) {
                            await fbAuth.FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);
                            Get.to(() => const ForgotPasswordPage());
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernCard(
                  children: [
                    _buildModernListTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Log out from your account',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        bool shouldLogout =
                            await DialogHelper.showLogoutConfirmation(context);
                        if (shouldLogout) {
                          await AuthService().signOut();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Drivora AutoQuest',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFFFF7A30)).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFFFF7A30),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey[600],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
    );
  }
}
