import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/learnroot_auth_background.dart';

class RegistrationScreen extends StatefulWidget {
  final bool isDarkMode;

  const RegistrationScreen({super.key, this.isDarkMode = true});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isCreatingAccount = false;
  String? selectedGender;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final gender = selectedGender;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        gender == null) {
      _showMessage('Please complete every field and select your gender.');
      return;
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters long.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => isCreatingAccount = true);
    User? newlyCreatedUser;

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      newlyCreatedUser = credential.user;
      if (newlyCreatedUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'The account could not be created. Please try again.',
        );
      }

      try {
        await newlyCreatedUser.updateDisplayName(name);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newlyCreatedUser.uid)
            .set({
              'name': name,
              'email': email,
              'gender': gender,
              'learningLevel': 'Student',
              'provider': 'password',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (_) {
        // Avoid leaving an unusable auth account if its required profile
        // document could not be created.
        try {
          await newlyCreatedUser.delete();
        } catch (_) {
          // If cleanup is blocked, report the profile setup failure below.
        }
        rethrow;
      }

      if (!mounted) return;
      setState(() => isCreatingAccount = false);
      _showMessage('Account created successfully! Please sign in.');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isCreatingAccount = false);

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists. Please log in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password with at least 6 characters.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-up is not enabled in Firebase yet.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection and try again.';
          break;
        default:
          message =
              e.message ?? 'Could not create your account. Please try again.';
      }
      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      setState(() => isCreatingAccount = false);
      _showMessage(
        'Account setup failed while saving your profile. Check your Firebase permissions and try again.',
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
      hintStyle: TextStyle(color: _secondaryText),
      prefixIcon: Icon(icon, color: _secondaryText, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: _mainText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _brandMark() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, AppTheme.gradientPurpleEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: .26),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 27),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardColor.withValues(alpha: widget.isDarkMode ? .95 : .98),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _primaryColor.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(
              alpha: widget.isDarkMode ? .12 : .07,
            ),
            blurRadius: 45,
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
              'START YOUR JOURNEY',
              style: TextStyle(
                color: AppTheme.gradientPurpleEnd,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your account',
            style: TextStyle(
              color: _mainText,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'A personal space for better understanding and steady progress.',
            style: TextStyle(color: _secondaryText, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 23),
          _label('Full name'),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            style: TextStyle(color: _mainText),
            decoration: _inputDecoration(
              hintText: 'Enter your full name',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 17),
          _label('Email address'),
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
          const SizedBox(height: 17),
          _label('Gender'),
          DropdownButtonFormField<String>(
            initialValue: selectedGender,
            dropdownColor: _cardColor,
            style: TextStyle(color: _mainText, fontSize: 13),
            decoration: _inputDecoration(
              hintText: 'Select your gender',
              icon: Icons.person_search_outlined,
            ),
            items: const [
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Male', child: Text('Male')),
            ],
            onChanged: isCreatingAccount
                ? null
                : (value) => setState(() => selectedGender = value),
          ),
          const SizedBox(height: 17),
          _label('Password'),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            style: TextStyle(color: _mainText),
            decoration: _inputDecoration(
              hintText: 'Create a password (6+ characters)',
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
          const SizedBox(height: 17),
          _label('Confirm password'),
          TextField(
            controller: confirmPasswordController,
            obscureText: hideConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => isCreatingAccount ? null : _createAccount(),
            style: TextStyle(color: _mainText),
            decoration: _inputDecoration(
              hintText: 'Enter the password again',
              icon: Icons.verified_user_outlined,
              suffixIcon: IconButton(
                tooltip: hideConfirmPassword
                    ? 'Show password'
                    : 'Hide password',
                icon: Icon(
                  hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _secondaryText,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => hideConfirmPassword = !hideConfirmPassword),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                    color: _primaryColor.withValues(alpha: .25),
                    blurRadius: 17,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isCreatingAccount ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isCreatingAccount
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create account',
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
          const SizedBox(height: 17),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: _secondaryText, fontSize: 12),
                ),
                TextButton(
                  onPressed: isCreatingAccount
                      ? null
                      : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.gradientPurpleEnd,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Sign in',
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

  Widget _buildBrandPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            _brandMark(),
            const SizedBox(width: 14),
            Text(
              'LearnRoot',
              style: TextStyle(
                color: _mainText,
                fontSize: 29,
                fontWeight: FontWeight.w800,
                letterSpacing: -.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 38),
        Text(
          'Make learning\nfeel connected.',
          style: TextStyle(
            color: _mainText,
            fontSize: 43,
            height: 1.12,
            letterSpacing: -1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          'Create your account to discover prerequisites, revise smarter, and learn concepts at your own pace.',
          style: TextStyle(color: _secondaryText, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 28),
        _benefit(Icons.account_tree_rounded, 'Understand how concepts connect'),
        const SizedBox(height: 14),
        _benefit(
          Icons.psychology_alt_rounded,
          'Get explanations when you need them',
        ),
        const SizedBox(height: 14),
        _benefit(Icons.auto_graph_rounded, 'Build progress one step at a time'),
      ],
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.gradientPurpleEnd, size: 19),
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
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 1180,
                          minHeight: constraints.maxHeight > 48
                              ? constraints.maxHeight - 48
                              : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _buildBrandPanel()),
                            const SizedBox(width: 56),
                            SizedBox(width: 520, child: _buildFormCard()),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 530),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _brandMark(),
                              const SizedBox(width: 13),
                              Text(
                                'LearnRoot',
                                style: TextStyle(
                                  color: _mainText,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.7,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Start building stronger foundations.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 23),
                          _buildFormCard(),
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
