import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Student';
  String _email = 'student@learnroot.com';
  String _learningLevel = 'Student';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        return;
      }

      String name = user.displayName ?? '';
      String email = user.email ?? '';

      // Get the user's profile from Firestore.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null) {
          if (data['name'] != null &&
              data['name'].toString().trim().isNotEmpty) {
            name = data['name'].toString().trim();
          }

          if (data['email'] != null &&
              data['email'].toString().trim().isNotEmpty) {
            email = data['email'].toString().trim();
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _name = name.isNotEmpty ? name : 'Student';
        _email = email.isNotEmpty ? email : 'student@learnroot.com';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return 'S';
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final levelController = TextEditingController(text: _learningLevel);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Learning Level',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newEmail = emailController.text.trim();
                final newLevel = levelController.text.trim();

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  Navigator.pop(context);
                  return;
                }

                try {
                  // Update Firebase display name.
                  if (newName.isNotEmpty) {
                    await user.updateDisplayName(newName);
                  }

                  // Update Firestore profile.
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set(
                    {
                      'name': newName.isEmpty ? 'Student' : newName,
                      'email': newEmail.isEmpty
                          ? (user.email ?? 'student@learnroot.com')
                          : newEmail,
                      'learningLevel':
                          newLevel.isEmpty ? 'Student' : newLevel,
                    },
                    SetOptions(merge: true),
                  );

                  if (!mounted) return;

                  setState(() {
                    _name =
                        newName.isEmpty ? 'Student' : newName;

                    _email = newEmail.isEmpty
                        ? (user.email ?? 'student@learnroot.com')
                        : newEmail;

                    _learningLevel =
                        newLevel.isEmpty ? 'Student' : newLevel;
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not update profile. Please try again.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    levelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearnRootColors.background,

      appBar: AppBar(
        backgroundColor: LearnRootColors.background,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: LearnRootColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: LearnRootColors.textPrimary,
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // PROFILE INITIALS
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: LearnRootColors.primary,
                        child: Text(
                          _getInitials(_name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // NAME
                      Text(
                        _name,
                        style: const TextStyle(
                          color: LearnRootColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // EMAIL
                      Text(
                        _email,
                        style: const TextStyle(
                          color: LearnRootColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _profileCard(
                        Icons.person_outline,
                        'Name',
                        _name,
                      ),

                      _profileCard(
                        Icons.email_outlined,
                        'Email',
                        _email,
                      ),

                      _profileCard(
                        Icons.school_outlined,
                        'Learning Level',
                        _learningLevel,
                      ),

                      const SizedBox(height: 10),

                      // EDIT PROFILE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                LearnRootColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // BACK TO DASHBOARD
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                LearnRootColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _profileCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LearnRootColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: LearnRootColors.primary,
            size: 24,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: LearnRootColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: LearnRootColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}