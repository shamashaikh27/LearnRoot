import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LearnRootApp());
}

class LearnRootApp extends StatefulWidget {
  const LearnRootApp({super.key});

  @override
  State<LearnRootApp> createState() => _LearnRootAppState();
}

class _LearnRootAppState extends State<LearnRootApp> {
  static const String _themePreferenceKey = 'learnroot_theme_mode';

  late final Stream<User?> _authStateChanges = FirebaseAuth.instance
      .authStateChanges();

  ThemeMode _themeMode = ThemeMode.dark;
  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedMode = preferences.getString(_themePreferenceKey);

      if (!mounted) return;

      setState(() {
        switch (savedMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          case 'dark':
          default:
            _themeMode = ThemeMode.dark;
        }

        _themeLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _themeLoaded = true;
      });
    }
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    if (!mounted) return;

    setState(() {
      _themeMode = mode;
    });

    try {
      final preferences = await SharedPreferences.getInstance();

      final savedMode = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

      await preferences.setString(_themePreferenceKey, savedMode);
    } catch (_) {
      // The selected theme still works for the current session.
    }
  }

  bool get _isEffectivelyDark {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnRoot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: !_themeLoaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : StreamBuilder<User?>(
              stream: _authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Unable to check your login status. Please restart the app.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final user = snapshot.data;

                if (user == null) {
                  return LoginScreen(
                    onThemeChanged: _changeTheme,
                    isDarkMode: _isEffectivelyDark,
                  );
                }

                return HomeScreen(
                  onThemeChanged: _changeTheme,
                  isDarkMode: _isEffectivelyDark,
                  gender: 'Male',
                );
              },
            ),
    );
  }
}
