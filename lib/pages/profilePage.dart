import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    bool isGoogleUser = false;
    String? photoUrl;
    String displayName = user?.displayName ?? 'User';
    String email = user?.email ?? 'example@mail.com';

    if (user != null) {
      for (var provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          isGoogleUser = true;
          photoUrl = provider.photoURL;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFFF7A30).withOpacity(0.2),
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl)
                  : const AssetImage("assets/default_profile.png")
                        as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            if (!isGoogleUser)
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (!isGoogleUser) const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: const Color(0xFFFF7A30)),
                    title: const Text('My Info'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  if (!isGoogleUser) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.lock_reset,
                        color: const Color(0xFFFF7A30),
                      ),
                      title: const Text('Forget Password?'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        if (email.isNotEmpty) {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent! Check your inbox.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: const Color(0xFFFF7A30)),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
