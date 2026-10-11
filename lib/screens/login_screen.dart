import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_theme.dart';
import '../widgets/learnroot_auth_background.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

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
      final data = userDoc.data();
      if (data != null && data['gender'] != null) {
        return data['gender'].toString();
      }
    } catch (_) {
      // Authentication should still proceed if the profile cannot be read.
    }
    return 'Male';
  }

  void _openHome(String gender) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          onThemeChanged: widget.onThemeChanged,
          isDarkMode: widget.isDarkMode,
          gender: gender,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() => isLoggingIn = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
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
      setState(() => isLoggingIn = false);
      _openHome(gender);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoggingIn = false);

      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email or password is incorrect. Please try again.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection and try again.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoggingIn = false);
      _showMessage('Something went wrong. Please try again.');
    }
  }

  Future<void> _loginWithGoogle() async {
    if (isGoogleLoggingIn || isLoggingIn) return;
    setState(() => isGoogleLoggingIn = true);

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      final user = userCredential.user;
      if (user == null) throw Exception('Google user not found.');

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
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
      setState(() => isGoogleLoggingIn = false);
      _openHome(gender);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isGoogleLoggingIn = false);
      String message = e.message ?? 'Google sign-in failed.';
      if (e.code == 'popup-closed-by-user') {
        message = 'Google sign-in was cancelled.';
      } else if (e.code == 'popup-blocked') {
        message = 'Allow popups in your browser and try again.';
      }
      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      setState(() => isGoogleLoggingIn = false);
      _showMessage('Google sign-in failed. Please try again.');
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: _secondaryText),
      prefixIcon: Icon(icon, color: _secondaryText, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _secondaryText.withValues(alpha: .12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  Widget _brandMark({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, AppTheme.gradientPurpleEnd],
        ),
        borderRadius: BorderRadius.circular(size * .30),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: .28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.school_rounded, color: Colors.white, size: size * .52),
    );
  }

  Widget _buildBrandPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            _brandMark(size: 54),
            const SizedBox(width: 15),
            Text(
              'LearnRoot',
              style: TextStyle(
                color: _mainText,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -.9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 38),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _primaryColor.withValues(alpha: .25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: AppTheme.gradientPurpleEnd,
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR PERSONAL AI LEARNING SPACE',
                style: TextStyle(
                  color: _mainText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Every concept.\nOne step at a time.',
          style: TextStyle(
            color: _mainText,
            fontSize: 43,
            height: 1.12,
            letterSpacing: -1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Build strong foundations, uncover learning gaps, and turn difficult topics into clear ideas.',
          style: TextStyle(color: _secondaryText, fontSize: 16, height: 1.7),
        ),
        const SizedBox(height: 28),
        _featureLine(
          Icons.account_tree_rounded,
          'Learning paths that connect concepts',
        ),
        const SizedBox(height: 15),
        _featureLine(
          Icons.auto_awesome_rounded,
          'AI-powered explanations and revision',
        ),
        const SizedBox(height: 15),
        _featureLine(Icons.insights_rounded, 'A clearer view of your progress'),
        const SizedBox(height: 34),
        _miniLearningGraph(),
      ],
    );
  }

  Widget _featureLine(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.gradientPurpleEnd, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _mainText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniLearningGraph() {
    final surface = widget.isDarkMode
        ? Colors.white.withValues(alpha: .035)
        : Colors.white.withValues(alpha: .55);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _secondaryText.withValues(alpha: .13)),
      ),
      child: Row(
        children: [
          _graphNode('Learn', Icons.menu_book_rounded),
          Expanded(
            child: Container(
              height: 1,
              color: _primaryColor.withValues(alpha: .55),
            ),
          ),
          _graphNode('Connect', Icons.hub_rounded),
          Expanded(
            child: Container(
              height: 1,
              color: _primaryColor.withValues(alpha: .55),
            ),
          ),
          _graphNode('Grow', Icons.trending_up_rounded),
        ],
      ),
    );
  }

  Widget _graphNode(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primaryColor.withValues(alpha: .22),
                AppTheme.gradientPurpleEnd.withValues(alpha: .10),
              ],
            ),
            border: Border.all(color: _primaryColor.withValues(alpha: .28)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.gradientPurpleEnd, size: 20),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: _secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _cardColor.withValues(alpha: widget.isDarkMode ? .94 : .97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _primaryColor.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(
              alpha: widget.isDarkMode ? .13 : .08,
            ),
            blurRadius: 50,
            spreadRadius: 1,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'WELCOME BACK',
              style: TextStyle(
                color: AppTheme.gradientPurpleEnd,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Sign in to LearnRoot',
            style: TextStyle(
              color: _mainText,
              fontSize: 26,
              letterSpacing: -.6,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick up where your learning journey left off.',
            style: TextStyle(color: _secondaryText, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 28),
          _fieldLabel('Email address'),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            style: TextStyle(color: _mainText),
            decoration: _inputDecoration(
              hintText: 'you@example.com',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 20),
          _fieldLabel('Password'),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) =>
                (isLoggingIn || isGoogleLoggingIn) ? null : _login(),
            style: TextStyle(color: _mainText),
            decoration: _inputDecoration(
              hintText: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: hidePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _secondaryText,
                  size: 20,
                ),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, AppTheme.gradientPurpleEnd],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: .28),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (isLoggingIn || isGoogleLoggingIn) ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoggingIn
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue learning',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 9),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(color: _secondaryText.withValues(alpha: .22)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: _secondaryText.withValues(alpha: .22)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: (isLoggingIn || isGoogleLoggingIn)
                  ? null
                  : _loginWithGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: _mainText,
                side: BorderSide(color: _secondaryText.withValues(alpha: .24)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isGoogleLoggingIn
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: _mainText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 21),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "New to LearnRoot? ",
                  style: TextStyle(color: _secondaryText, fontSize: 12),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.gradientPurpleEnd,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RegistrationScreen(isDarkMode: widget.isDarkMode),
                      ),
                    );
                  },
                  child: const Text(
                    'Create an account',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: TextStyle(
      color: _mainText,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: LearnRootAuthBackground(isDark: widget.isDarkMode),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1020;
                if (wide) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 1180,
                          minHeight: constraints.maxHeight > 56
                              ? constraints.maxHeight - 56
                              : 0.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildBrandPanel()),
                            const SizedBox(width: 70),
                            SizedBox(width: 445, child: _buildLoginCard()),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: Column(
                        children: [
                          _brandMark(size: 56),
                          const SizedBox(height: 14),
                          Text(
                            'LearnRoot',
                            style: TextStyle(
                              color: _mainText,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.8,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Learn smarter. Learn step by step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _secondaryText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildLoginCard(),
                          const SizedBox(height: 18),
                          Text(
                            'A stronger foundation starts with one small step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
