import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode selectedThemeMode;

  @override
  void initState() {
    super.initState();
    selectedThemeMode = widget.themeMode;
  }

  void _changeTheme(ThemeMode value) {
    setState(() {
      selectedThemeMode = value;
    });

    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: selectedThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  _changeTheme(value);
                }
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: const Text('Dark'),
                    subtitle: const Text(
                      'Use the dark LearnRoot theme.',
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: const Text('Light'),
                    subtitle: const Text(
                      'Use the light LearnRoot theme.',
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: const Text('System'),
                    subtitle: const Text(
                      'Follow your device setting.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}