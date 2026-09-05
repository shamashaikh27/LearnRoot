import 'package:flutter/material.dart';
import 'module2/screens/subject_screen.dart';

void main() {
  runApp(const LearnRootApp());
}

class LearnRootApp extends StatelessWidget {
  const LearnRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnRoot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const SubjectScreen(),
    );
  }
}