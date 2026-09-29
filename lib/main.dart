import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
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

      theme: LearnRootTheme.lightTheme,
      darkTheme: LearnRootTheme.darkTheme,
      themeMode: _themeMode,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase is checking the current login session.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // No user is logged in.
          if (!snapshot.hasData || snapshot.data == null) {
            return LoginScreen(
              onThemeChanged: _changeTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            );
          }

          // A user is already logged in.
          final User user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              String gender = 'Male';

              if (userSnapshot.hasData &&
                  userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data();

                if (data != null &&
                    data['gender'] != null &&
                    data['gender'].toString().isNotEmpty) {
                  gender = data['gender'].toString();
                }
              }

              return HomeScreen(
                onThemeChanged: _changeTheme,
                isDarkMode: _themeMode == ThemeMode.dark,
                gender: gender,
              );
            },
          );
        },
      ),
    );
  }
}