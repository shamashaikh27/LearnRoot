import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
void initState() {
  super.initState();
  _loadProfile();
}

Future<void> _loadProfile() async {
  final prefs = await SharedPreferences.getInstance();

  final savedName = prefs.getString('registered_name');
  final savedEmail = prefs.getString('registered_email');

  if (!mounted) return;

  setState(() {
    if (savedName != null && savedName.isNotEmpty) {
      _name = savedName;
    }

    if (savedEmail != null && savedEmail.isNotEmpty) {
      _email = savedEmail;
    }
  });
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

  void _editProfile() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final levelController = TextEditingController(text: _learningLevel);

    showDialog(
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
              onPressed: () {
                setState(() {
                  _name = nameController.text.trim().isEmpty
                      ? 'Student'
                      : nameController.text.trim();

                  _email = emailController.text.trim().isEmpty
                      ? 'student@learnroot.com'
                      : emailController.text.trim();

                  _learningLevel =
                      levelController.text.trim().isEmpty
                          ? 'Student'
                          : levelController.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

      body: SingleChildScrollView(
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

                Text(
                  _name,
                  style: const TextStyle(
                    color: LearnRootColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LearnRootColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LearnRootColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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