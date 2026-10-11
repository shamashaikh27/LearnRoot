import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  bool _isSaving = false;

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

      String name = user.displayName?.trim() ?? '';
      String email = user.email?.trim() ?? '';
      String learningLevel = 'Student';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();

      if (data != null) {
        final firestoreName =
            data['name']?.toString().trim() ?? '';
        final firestoreEmail =
            data['email']?.toString().trim() ?? '';
        final firestoreLevel =
            data['learningLevel']?.toString().trim() ?? '';

        if (firestoreName.isNotEmpty) {
          name = firestoreName;
        }

        if (firestoreEmail.isNotEmpty) {
          email = firestoreEmail;
        }

        if (firestoreLevel.isNotEmpty) {
          learningLevel = firestoreLevel;
        }
      }

      if (name.isEmpty) {
        name = email.isNotEmpty
            ? email.split('@').first
            : 'Student';
      }

      if (email.isEmpty) {
        email = 'student@learnroot.com';
      }

      if (!mounted) return;

      setState(() {
        _name = name;
        _email = email;
        _learningLevel = learningLevel;
        _isLoading = false;
      });
    } catch (_) {
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

  Future<void> _saveProfile({
    required String name,
    required String learningLevel,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final cleanName =
          name.trim().isEmpty ? 'Student' : name.trim();

      final cleanLevel = learningLevel.trim().isEmpty
          ? 'Student'
          : learningLevel.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': cleanName,
          'email': user.email ?? _email,
          'learningLevel': cleanLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (user.displayName != cleanName) {
        await user.updateDisplayName(cleanName);
        await user.reload();
      }

      if (!mounted) return;

      setState(() {
        _name = cleanName;
        _email = user.email ?? _email;
        _learningLevel = cleanLevel;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update the profile. Please try again.',
          ),
        ),
      );
    }
  }

  void _editProfile() {
    final nameController =
        TextEditingController(text: _name);
    final levelController =
        TextEditingController(text: _learningLevel);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
                    prefixIcon:
                        Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: _email,
                  readOnly: true,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Learning Level',
                    prefixIcon:
                        Icon(Icons.school_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      await _saveProfile(
                        name: nameController.text,
                        learningLevel:
                            levelController.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      nameController.dispose();
                      levelController.dispose();
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      levelController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read colors from the currently active app theme.
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Scaffold(
      backgroundColor: themeColors.background,

      appBar: AppBar(
        backgroundColor: themeColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Profile',
          style: TextStyle(
            color: themeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeColors.textPrimary,
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

                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            LearnRootColors.primary,
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

                      Text(
                        _name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _profileCard(
                        context,
                        Icons.person_outline,
                        'Name',
                        _name,
                      ),

                      _profileCard(
                        context,
                        Icons.email_outlined,
                        'Email',
                        _email,
                      ),

                      _profileCard(
                        context,
                        Icons.school_outlined,
                        'Learning Level',
                        _learningLevel,
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                LearnRootColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
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

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                          label: const Text(
                            'Back to Dashboard',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                LearnRootColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
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
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColors.border,
        ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: themeColors.textPrimary,
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
