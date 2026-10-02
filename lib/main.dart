import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LearnRootApp());
}

class LearnRootApp extends StatefulWidget {
  const LearnRootApp({super.key});

  @override
  State<LearnRootApp> createState() => _LearnRootAppState();
}

class _LearnRootAppState extends State<LearnRootApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnRoot',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      home: LoginScreen(
        onThemeChanged: _changeTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}