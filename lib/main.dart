import 'package:flutter/material.dart';
import 'module4/module4.dart';

void main() {
  runApp(const LearnRootApp());
}

class LearnRootApp extends StatelessWidget {
  const LearnRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnRoot - Module 4',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: Module4HomeScreen(),
    );
  }
}