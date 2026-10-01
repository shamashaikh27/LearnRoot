import 'package:flutter/material.dart';

import 'subject_screen.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubjectScreen(
      themeMode: Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      onThemeChanged: (mode) {},
    );
  }
}