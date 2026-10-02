import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'registration_screen.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
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
  bool isGoogleLoggingIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<String> _getGender(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['gender'] != null) {
          return data['gender'].toString();
        }
      }
    } catch (_) {
      // Login should still continue if the profile document cannot be read.
    }

    return 'Male';
  }

  void _openHome(String gender) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          onThemeChanged: widget.onThemeChanged,
          isDarkMode: widget.isDarkMode,
          gender: gender,
        ),
      ),
    );
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

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User account could not be found.',
        );
      }

      final gender = await _getGender(user);

      if (!mounted) return;

      setState(() {
        isLoggingIn = false;
      });

      _openHome(gender);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoggingIn = false;
      });

      String message = 'Login failed. Please try again.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Firebase error: ${e.code}\n${e.message ?? ''}';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoggingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    if (isGoogleLoggingIn) return;

    setState(() {
      isGoogleLoggingIn = true;
    });

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize();

        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google user not found.');
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'name': user.displayName ?? 'LearnRoot User',
          'email': user.email ?? '',
          'gender': 'Male',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final gender = await _getGender(user);

      if (!mounted) return;

      setState(() {
        isGoogleLoggingIn = false;
      });

      _openHome(gender);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isGoogleLoggingIn = false;
      });

      String message = e.message ?? 'Google sign-in failed.';

      if (e.code == 'popup-closed-by-user') {
        message = 'Google sign-in was cancelled.';
      } else if (e.code == 'popup-blocked') {
        message =
            'The Google sign-in window was blocked. Please allow popups and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGoogleLoggingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: _secondaryText,
      ),
      prefixIcon: Icon(
        icon,
        color: _secondaryText,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppTheme.primaryPurple,
          width: 1.2,
        ),
      ),
    );
  }

  Color get _backgroundColor =>
      widget.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;

  Color get _cardColor =>
      widget.isDarkMode ? AppTheme.darkCard : AppTheme.lightCard;

  Color get _inputBackground =>
      widget.isDarkMode ? AppTheme.darkSecondary : AppTheme.lightSecondary;

  Color get _primaryColor => AppTheme.primaryPurple;

  Color get _mainText =>
      widget.isDarkMode ? AppTheme.darkMainText : AppTheme.lightMainText;

  Color get _secondaryText => widget.isDarkMode
      ? AppTheme.darkSecondaryText
      : AppTheme.lightSecondaryText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
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
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LearnRoot',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: _mainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn smarter. Learn step by step.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _secondaryText,
                    ),
                  ),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: _mainText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue your learning journey.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: _mainText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: _mainText,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter your email',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Password',
                          style: TextStyle(
                            color: _mainText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          style: TextStyle(
                            color: _mainText,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter your password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _secondaryText,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
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
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primaryColor.withValues(alpha: 0.55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: _secondaryText.withValues(alpha: 0.25),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: _secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: _secondaryText.withValues(alpha: 0.25),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed:
                                isGoogleLoggingIn ? null : _loginWithGoogle,
                            icon: isGoogleLoggingIn
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.g_mobiledata_rounded),
                            label: Text(
                              isGoogleLoggingIn
                                  ? 'Signing in...'
                                  : 'Continue with Google',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _mainText,
                              side: BorderSide(
                                color: _secondaryText.withValues(alpha: 0.25),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                            child: Text(
                              "Don't have an account? Register",
                              style: TextStyle(
                                color: _secondaryText,
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
