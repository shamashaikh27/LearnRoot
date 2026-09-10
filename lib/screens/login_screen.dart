import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'registration_screen.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final bool isDarkMode;

  const LoginScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoggingIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
        ),
      );
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final registeredEmail = prefs.getString('registered_email');
    final registeredPassword = prefs.getString('registered_password');

    // Get the gender saved during registration.
    final registeredGender = prefs.getString('registered_gender');

    final isValidLogin = registeredEmail != null &&
        registeredPassword != null &&
        email == registeredEmail.toLowerCase() &&
        password == registeredPassword;

    if (!mounted) return;

    setState(() {
      isLoggingIn = false;
    });

    if (!isValidLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Please check your email and password.',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          onThemeChanged: widget.onThemeChanged,
          isDarkMode: widget.isDarkMode,
          gender: registeredGender ?? 'Male',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearnRootColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LearnRootColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'LearnRoot',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: LearnRootColors.darkTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Learn smarter. Learn step by step.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: LearnRootColors.darkTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 42),

                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: LearnRootColors.darkCard,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: LearnRootColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: LearnRootColors.darkTextPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Login to continue your learning journey.',
                          style: TextStyle(
                            fontSize: 14,
                            color: LearnRootColors.darkTextSecondary,
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Email',
                          style: TextStyle(
                            color: LearnRootColors.darkTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: LearnRootColors.darkTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: const TextStyle(
                              color: LearnRootColors.darkTextSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: LearnRootColors.darkTextSecondary,
                            ),
                            filled: true,
                            fillColor: LearnRootColors.darkBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Password',
                          style: TextStyle(
                            color: LearnRootColors.darkTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          style: const TextStyle(
                            color: LearnRootColors.darkTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(
                              color: LearnRootColors.darkTextSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: LearnRootColors.darkTextSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color:
                                    LearnRootColors.darkTextSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: LearnRootColors.darkBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoggingIn ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  LearnRootColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoggingIn
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(
                                color:
                                    LearnRootColors.darkTextSecondary,
                              ),
                            ),
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
      ),
    );
  }
}