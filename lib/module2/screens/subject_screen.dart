import 'package:flutter/material.dart';
import 'settings_screen.dart';

import '../data/syllabus_data.dart';
import 'graph_screen.dart';

class SubjectScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SubjectScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  final List<String> subjects = [
    'C Programming',
    'Data Structures',
    'Operating Systems',
    'Computer Networks',
    'DBMS',
    'OOPs – Java',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final filteredSubjects = subjects.where((subject) {
      return subject.toLowerCase().contains(
            searchText.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'LearnRoot',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(
              Icons.settings_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    themeMode: widget.themeMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search subject...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.55 : 0.50,
                          ),
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Expanded(
            child: filteredSubjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 55,
                          color: colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.55 : 0.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching subject found.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject =
                          filteredSubjects[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                colorScheme.onSurface.withValues(
                              alpha: isDark ? 0.05 : 0.08,
                            ),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.14),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            subject,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                            color:
                                colorScheme.onSurface.withValues(
                              alpha: isDark ? 0.55 : 0.50,
                            ),
                          ),
                          onTap: () {
                            final subjectTopics =
                                syllabusTopics
                                    .where(
                              (topic) =>
                                  topic.subject ==
                                  subject,
                            )
                                    .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings:
                                    const RouteSettings(
                                  name: '/topicList',
                                ),
                                builder: (_) =>
                                    GraphScreen(
                                  subject: subject,
                                  topics: subjectTopics,
                                ),
                              ),
                            );
                          },
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