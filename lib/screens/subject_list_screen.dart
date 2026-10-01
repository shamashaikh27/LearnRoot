import 'package:flutter/material.dart';

import 'subject_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _subjects = [
    'C Programming',
    'Data Structures',
    'Operating Systems',
    'Computer Networks',
    'DBMS',
    'OOPs – Java',
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  List<String> get _filteredSubjects {
    if (_searchQuery.isEmpty) {
      return _subjects;
    }

    return _subjects
        .where(
          (subject) => subject.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void _openSubject(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectScreen(
          subject: subject,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;

    final cardColor = isDark
        ? const Color(0xFF171A38)
        : Colors.white;

    final borderColor = isDark
        ? const Color(0xFF343063)
        : const Color(0xFFE5E2EF);

    final primaryText = isDark
        ? Colors.white
        : const Color(0xFF1D1B2C);

    final secondaryText = isDark
        ? const Color(0xFFBDB9D8)
        : const Color(0xFF6B687A);

    final searchBackground = isDark
        ? const Color(0xFF11152F)
        : const Color(0xFFF5F3FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LearnRoot',
          style: TextStyle(
            color: primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: searchBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15,
                      ),
                      cursorColor: const Color(0xFF6C63FF),
                      decoration: InputDecoration(
                        hintText: 'Search subject...',
                        hintStyle: TextStyle(
                          color: secondaryText,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: secondaryText,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: secondaryText,
                                ),
                                onPressed: _searchController.clear,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'Subjects',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Select a subject to explore its prerequisite learning path.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: _filteredSubjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: secondaryText,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No subjects found',
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try searching for another subject.',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredSubjects.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final subject = _filteredSubjects[index];

                              return _buildSubjectCard(
                                context,
                                subject,
                                cardColor,
                                borderColor,
                                primaryText,
                                secondaryText,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String subject,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSubject(subject),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 5),
                color: isDark
                    ? const Color(0x22000000)
                    : const Color(0x10000000),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: secondaryText,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }
}