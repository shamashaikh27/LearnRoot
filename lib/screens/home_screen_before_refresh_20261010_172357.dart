//PART1
// ============================================================
// IMPORTS, HOME SCREEN AND VARIABLES
// ============================================================
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';
import '../module2/data/syllabus_data.dart';
import '../module2/models/topic.dart';
import '../module2/screens/topic_details_screen.dart';
import 'profile_screen.dart';
import 'subject_screen.dart';
import 'subject_list_screen.dart';
import 'one_shot_revision_screen.dart';
import '../module4/models/topic.dart' as module4;
import '../module4/screens/quiz_screen.dart' as module4_quiz;

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final bool isDarkMode;
  final String gender;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.gender,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Student';

  final TextEditingController _aiTopicController =
      TextEditingController(text: 'Pointers');
  final TextEditingController _aiDoubtController =
      TextEditingController();
  final TextEditingController _revisionTopicController =
      TextEditingController();

  String _revisionSubject = 'C Programming';
  String _learningPathSubject = 'Data Structures';
  int _dailyGoalMinutes = 60;
  String _preferredLearningStyle = 'Visual';
  bool _notificationsEnabled = true;
  bool _settingsLoading = true;

  // Short Revision always reads topics from the existing LearnRoot syllabus.
  // This keeps the revision page synchronized with the actual subject/topic data.
  final Map<String, List<String>> _revisionSubjectAliases = const {
    'C Programming': ['C Programming'],
    'Data Structures': ['Data Structures'],
    'OOP Java': ['OOP Java', 'OOPs – Java', 'OOPs - Java'],
    'Computer Networks': ['Computer Networks'],
    'Operating System': ['Operating System', 'Operating Systems'],
    'DBMS': ['DBMS'],
  };

  bool _isAskingDoubt = false;
  String? _aiDoubtAnswer;


  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserPreferences();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      String? name;

      // First use the name stored in the user's Firestore profile.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();
      if (data != null && data['name'] != null) {
        final firestoreName = data['name'].toString().trim();
        if (firestoreName.isNotEmpty) {
          name = firestoreName;
        }
      }

      // Google/Firebase account display name is the next fallback.
      if (name == null || name.isEmpty) {
        final displayName = user.displayName?.trim();
        if (displayName != null && displayName.isNotEmpty) {
          name = displayName;
        }
      }

      // Last fallback: use the part before @ in the email.
      if (name == null || name.isEmpty) {
        final email = user.email?.trim();
        if (email != null && email.isNotEmpty) {
          name = email.split('@').first;
        }
      }

      if (!mounted || name == null || name.isEmpty) {
        return;
      }

      setState(() {
        _userName = name!;
      });
    } catch (_) {
      // Keep the default name if the profile cannot be loaded.
    }
  }

  DocumentReference<Map<String, dynamic>>? get _preferencesDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences');
  }

  Future<void> _loadUserPreferences() async {
    try {
      final reference = _preferencesDocument;
      if (reference == null) {
        if (mounted) setState(() => _settingsLoading = false);
        return;
      }
      final snapshot = await reference.get();
      final data = snapshot.data() ?? <String, dynamic>{};
      if (!mounted) return;
      final savedTheme = data['themeMode']?.toString();
      if (savedTheme == 'dark') {
        widget.onThemeChanged(ThemeMode.dark);
      } else if (savedTheme == 'light') {
        widget.onThemeChanged(ThemeMode.light);
      }
      setState(() {
        _dailyGoalMinutes = (data['dailyGoalMinutes'] as num?)?.toInt() ?? 60;
        _preferredLearningStyle =
            data['preferredLearningStyle']?.toString() ?? 'Visual';
        _notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
        _settingsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _settingsLoading = false);
    }
  }

  Future<void> _saveUserPreferences(Map<String, dynamic> values) async {
    try {
      final reference = _preferencesDocument;
      if (reference == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in to save your preferences.')),
          );
        }
        return;
      }
      await reference.set({
        ...values,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save preferences: $e')),
        );
      }
    }
  }

  Future<void> _chooseDailyGoal() async {
    final choice = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Daily study goal'),
        children: [30, 45, 60, 90, 120].map((minutes) {
          final label = minutes == 60
              ? '1 hour'
              : minutes == 120
                  ? '2 hours'
                  : '$minutes minutes';
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, minutes),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                if (_dailyGoalMinutes == minutes)
                  const Icon(Icons.check_circle_rounded, color: LearnRootColors.primary),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() => _dailyGoalMinutes = choice);
    await _saveUserPreferences({'dailyGoalMinutes': choice});
  }

  Future<void> _chooseLearningStyle() async {
    const styles = ['Visual', 'Reading', 'Practice', 'Mixed'];
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Preferred learning style'),
        children: styles.map((style) => SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, style),
          child: Row(
            children: [
              Expanded(child: Text(style)),
              if (_preferredLearningStyle == style)
                const Icon(Icons.check_circle_rounded, color: LearnRootColors.primary),
            ],
          ),
        )).toList(),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() => _preferredLearningStyle = choice);
    await _saveUserPreferences({'preferredLearningStyle': choice});
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again to continue your learning journey.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _aiTopicController.dispose();
    _aiDoubtController.dispose();
    _revisionTopicController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  if (parts.isNotEmpty && parts[0].isNotEmpty) {
    return parts[0][0].toUpperCase();
  }

  return 'S';
}

  int selectedMenu = 0;
  bool isSidebarCollapsed = false;

  final List<String> menuItems = [
    'Dashboard',
    'Learning Path',
    'Subjects',
    'AI Tutor',
    'Short Revision',
    'Progress',
    'Quizzes',
    'Settings',
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_outlined,
    Icons.account_tree_outlined,
    Icons.menu_book_outlined,
    Icons.auto_awesome_outlined,
    Icons.bolt_outlined,
    Icons.bar_chart_outlined,
    Icons.quiz_outlined,
    Icons.settings_outlined,
  ];

  final List<String> subjects = [
    'C Programming',
    'Data Structures',
    'OOP Java',
    'Computer Networks',
    'Operating System',
    'DBMS',
  ];

  final List<IconData> subjectIcons = [
    Icons.code,
    Icons.account_tree,
    Icons.code_rounded,
    Icons.lan_outlined,
    Icons.computer_outlined,
    Icons.storage_outlined,
  ];

// ============================================================
// SHORT REVISION NAVIGATION
// ============================================================

List<String> get _revisionTopics {
  final aliases = _revisionSubjectAliases[_revisionSubject] ?? const <String>[];

  return syllabusTopics
      .where(
        (topic) => aliases.any(
          (alias) => topic.subject.trim().toLowerCase() == alias.toLowerCase(),
        ),
      )
      .map((topic) => topic.name.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
}

List<String> get _filteredRevisionTopics {
  final query = _revisionTopicController.text.trim().toLowerCase();
  if (query.isEmpty) return _revisionTopics;

  return _revisionTopics
      .where((topic) => topic.toLowerCase().contains(query))
      .toList();
}

void _selectRevisionSubject(String? subject) {
  if (subject == null || subject.isEmpty) return;

  setState(() {
    _revisionSubject = subject;
    _revisionTopicController.clear();
  });
}

void _selectRevisionTopic(String topic) {
  setState(() {
    _revisionTopicController.text = topic;
  });
}

void _openRevisionForTopic() {
  final topic = _revisionTopicController.text.trim();

  if (topic.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a topic to revise.'),
      ),
    );
    return;
  }

  final validTopic = _revisionTopics.any(
    (item) => item.toLowerCase() == topic.toLowerCase(),
  );

  if (!validTopic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please choose a topic from $_revisionSubject.'),
      ),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return OneShotRevisionScreen(
          subject: _revisionSubject,
          topic: _revisionTopics.firstWhere(
            (item) => item.toLowerCase() == topic.toLowerCase(),
          ),
        );
      },
    ),
  );
}

Widget _buildRevisionSearchBox() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Subject',
        style: TextStyle(
          color: themeColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: themeColors.inputBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: themeColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _revisionSubject,
            isExpanded: true,
            dropdownColor: themeColors.inputBackground,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: themeColors.textSecondary,
            ),
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            items: subjects.map((subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: _selectRevisionSubject,
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Select Topic',
        style: TextStyle(
          color: themeColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Choose a topic from the selected LearnRoot subject.',
        style: TextStyle(
          color: themeColors.textSecondary,
          fontSize: 12,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 14),
      InkWell(
        onTap: _showRevisionTopicPicker,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: themeColors.inputBackground,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: themeColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: themeColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _revisionTopicController.text.trim().isEmpty
                      ? 'Search or select a topic...'
                      : _revisionTopicController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _revisionTopicController.text.trim().isEmpty
                        ? themeColors.textSecondary
                        : themeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: themeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _openRevisionForTopic,
          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
          label: const Text('Generate Revision'),
          style: ElevatedButton.styleFrom(
            backgroundColor: LearnRootColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<void> _showRevisionTopicPicker() async {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;
  final searchController = TextEditingController();

  // Use a full-screen route with an explicit Center so the picker is
  // positioned in the middle of the browser viewport, not anchored to a field.
  final selectedTopic = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: StatefulBuilder(
        builder: (context, setDialogState) {
          final query = searchController.text.trim().toLowerCase();
          final filteredTopics = _revisionTopics
              .where(
                (topic) => topic.toLowerCase().contains(query),
              )
              .toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 580,
                maxHeight: 620,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: themeColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: themeColors.border),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 28,
                      spreadRadius: 1,
                      color: Colors.black.withValues(alpha: 0.28),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 18, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: LearnRootColors.primary.withValues(
                                alpha: 0.14,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.quiz_outlined,
                              color: LearnRootColors.primary,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select Revision Topic',
                              style: TextStyle(
                                color: themeColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(
                              Icons.close_rounded,
                              color: themeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: (_) => setDialogState(() {}),
                        style: TextStyle(
                          color: themeColors.textPrimary,
                          fontSize: 13,
                        ),
                        cursorColor: LearnRootColors.primary,
                        decoration: InputDecoration(
                          hintText:
                              'Search topics in $_revisionSubject...',
                          hintStyle: TextStyle(
                            color: themeColors.textSecondary,
                            fontSize: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: themeColors.textSecondary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: themeColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide:
                                BorderSide(color: themeColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: LearnRootColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: themeColors.border,
                    ),
                    Expanded(
                      child: filteredTopics.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No matching topics found.',
                                  style: TextStyle(
                                    color: themeColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              itemCount: filteredTopics.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: themeColors.border,
                              ),
                              itemBuilder: (context, index) {
                                final topic = filteredTopics[index];
                                final selected =
                                    _revisionTopicController.text
                                            .trim()
                                            .toLowerCase() ==
                                        topic.toLowerCase();

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(dialogContext, topic);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: LearnRootColors.primary
                                                  .withValues(alpha: 0.10),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                            ),
                                            child: Icon(
                                              Icons.menu_book_outlined,
                                              size: 17,
                                              color: LearnRootColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              topic,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: themeColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: selected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            selected
                                                ? Icons.check_circle_rounded
                                                : Icons.chevron_right_rounded,
                                            size: 19,
                                            color: selected
                                                ? LearnRootColors.primary
                                                : themeColors.textSecondary,
                                          ),
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
              ),
            ),
          );
          },
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  searchController.dispose();

  if (selectedTopic != null && mounted) {
    _selectRevisionTopic(selectedTopic);
  }
}

// ============================================================
// SEARCH HANDLER
// ============================================================

void _handleSearch(String query) {
  final search = query.trim().toLowerCase();

  if (search.isEmpty) return;

  if (search == 'dashboard') {
    setState(() {
      selectedMenu = 0;
    });
    return;
  }

  if (search == 'learning path' ||
      search == 'learningpath') {
    setState(() {
      selectedMenu = 1;
    });
    return;
  }

  if (search == 'subjects' ||
      search == 'subject') {
    setState(() {
      selectedMenu = 2;
    });
    return;
  }

  if (search == 'ai tutor' ||
      search == 'ai' ||
      search == 'tutor') {
    setState(() {
      selectedMenu = 3;
    });
    return;
  }

  if (search == 'short revision' ||
      search == 'shortrevision' ||
      search == 'revision') {
    setState(() {
      selectedMenu = 4;
    });
    return;
  }

  if (search == 'progress') {
    setState(() {
      selectedMenu = 5;
    });
    return;
  }

  if (search == 'quizzes' ||
      search == 'quiz') {
    setState(() {
      selectedMenu = 6;
    });
    return;
  }

  if (search == 'settings' ||
      search == 'setting') {
    setState(() {
      selectedMenu = 7;
    });
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('No results found for "$query"'),
    ),
  );
}

  //PART2
  //PART2
// ============================================================
// BUILD METHOD + DESKTOP AND MOBILE LAYOUT
// ============================================================

@override
Widget build(BuildContext context) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 900) {
        return _buildMobileLayout(themeColors);
      }

      return Scaffold(
        backgroundColor: themeColors.background,
        body: _buildDesktopLayout(themeColors),
      );
    },
  );
}

// ============================================================
// DESKTOP LAYOUT
// ============================================================

Widget _buildDesktopLayout(
  LearnRootThemeColors themeColors,
) {
  return Container(
    color: themeColors.background,
    child: Row(
      children: [
        _buildSidebar(),

        Expanded(
          child: Column(
            children: [
              _buildTopBar(),

              Expanded(
                child: Container(
                  color: themeColors.background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: _buildSelectedPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// MOBILE LAYOUT
// ============================================================

Widget _buildMobileLayout(
  LearnRootThemeColors themeColors,
) {
  return Scaffold(
    backgroundColor: themeColors.background,

    drawer: Drawer(
      backgroundColor: themeColors.sidebar,

      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildLogo(),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(
                    index,
                    closeDrawer: true,
                  );
                },
              ),
            ),

            _buildProfileButton(
              closeDrawer: true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),

    body: Container(
      color: themeColors.background,
      child: Column(
        children: [
          _buildMobileTopBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _buildSelectedPage(),
            ),
          ),
        ],
      ),
    ),
  );
}

  //PART3
  //PART3
// ============================================================
// SIDEBAR
// ============================================================

Widget _buildSidebar() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    width: isSidebarCollapsed ? 80 : 250,
    color: themeColors.sidebar,
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 15),

          // LOGO + COLLAPSE BUTTON
          SizedBox(
            height: 55,
            child: Row(
              mainAxisAlignment: isSidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isSidebarCollapsed)
                  Expanded(
                    child: _buildLogo(),
                  ),

                IconButton(
                  tooltip: isSidebarCollapsed
                      ? 'Expand sidebar'
                      : 'Collapse sidebar',
                  onPressed: () {
                    setState(() {
                      isSidebarCollapsed =
                          !isSidebarCollapsed;
                    });
                  },
                  icon: Icon(
                    isSidebarCollapsed
                        ? Icons.menu_rounded
                        : Icons.menu_open_rounded,
                    color: themeColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // MENU
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isSidebarCollapsed ? 8 : 12,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(index);
              },
            ),
          ),

          // PROFILE
          _buildProfileButton(),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// ============================================================
// LOGO
// ============================================================

Widget _buildLogo() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Padding(
    padding: const EdgeInsets.only(left: 12),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: LearnRootColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          'LearnRoot',
          style: TextStyle(
            color: themeColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// MENU ITEM
// ============================================================

Widget _buildMenuItem(
  int index, {
  bool closeDrawer = false,
}) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool selected = selectedMenu == index;

  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () {
          if (index == 2) {
            if (closeDrawer) {
              Navigator.of(context).pop();
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubjectListScreen(),
              ),
            );
            return;
          }

          setState(() {
            selectedMenu = index;
          });

          if (closeDrawer) {
            Navigator.of(context).pop();
          }
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),

          padding: EdgeInsets.symmetric(
            horizontal:
                isSidebarCollapsed ? 0 : 14,
            vertical: 13,
          ),

          decoration: BoxDecoration(
            color: selected
                ? LearnRootColors.primary
                    .withOpacity(0.14)
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(12),

            border: selected
                ? Border.all(
                    color: LearnRootColors.primary
                        .withOpacity(0.30),
                  )
                : null,
          ),

          child: Row(
            mainAxisAlignment:
                isSidebarCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,

            children: [
              Icon(
                menuIcons[index],
                color: selected
                    ? LearnRootColors.primary
                    : themeColors.textSecondary,
                size: 21,
              ),

              if (!isSidebarCollapsed) ...[
                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    menuItems[index],
                    style: TextStyle(
                      color: selected
                          ? themeColors.textPrimary
                          : themeColors.textSecondary,
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration:
                        const BoxDecoration(
                      color: LearnRootColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// PROFILE BUTTON
// ============================================================

Widget _buildProfileButton({
  bool closeDrawer = false,
}) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal:
          isSidebarCollapsed ? 8 : 16,
    ),

    child: InkWell(
      borderRadius:
          BorderRadius.circular(14),

      onTap: () {
        if (closeDrawer) {
          Navigator.of(context).pop();
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfileScreen(),
          ),
        );
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),

        padding: EdgeInsets.all(
          isSidebarCollapsed ? 8 : 12,
        ),

        decoration: BoxDecoration(
          color: themeColors.card,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: themeColors.border,
          ),
        ),

        child: Row(
          mainAxisAlignment:
              isSidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,

          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  const BoxDecoration(
                color: LearnRootColors.primary,
                shape: BoxShape.circle,
              ),
              child:  Center(
                child: Text(
                  _getInitials(_userName),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (!isSidebarCollapsed) ...[
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: TextStyle(
                        color:
                            themeColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'View Profile',
                      style: TextStyle(
                        color:
                            themeColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color:
                    themeColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
  //PART4
  //PART4
// ============================================================
// TOP BAR + SELECTED PAGE
// ============================================================

Widget _buildTopBar() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return Container(
    height: 78,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: BoxDecoration(
      color: themeColors.background,
      border: Border(
        bottom: BorderSide(
          color: themeColors.border,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            menuItems[selectedMenu],
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // SEARCH
Container(
  width: 230,
  height: 42,
  decoration: BoxDecoration(
    color: themeColors.inputBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: themeColors.border,
    ),
  ),
  child: TextField(
    onSubmitted: _handleSearch,
    style: TextStyle(
      color: themeColors.textPrimary,
    ),
    cursorColor: LearnRootColors.primary,
    decoration: InputDecoration(
      hintText: 'Search...',
      hintStyle: TextStyle(
        color: themeColors.textSecondary,
      ),
      prefixIcon: Icon(
        Icons.search,
        color: themeColors.textSecondary,
        size: 20,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
    ),
  ),
),

        const SizedBox(width: 12),

        // NOTIFICATION
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notifications'),
        content: const Text(
          'You have no new notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
          },
          icon: Icon(
            Icons.notifications_none_rounded,
            color: themeColors.textSecondary,
          ),
        ),

        const SizedBox(width: 4),

        // THEME TOGGLE
        IconButton(
          tooltip: isDark
              ? 'Switch to light mode'
              : 'Switch to dark mode',
          onPressed: () {
            final currentBrightness =
                Theme.of(context).brightness;

            widget.onThemeChanged(
              currentBrightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: themeColors.textSecondary,
          ),
        ),

        const SizedBox(width: 8),

        // PROFILE
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ),
            );
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: LearnRootColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
  child: Text(
    _getInitials(_userName),
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// MOBILE TOP BAR
// ============================================================

Widget _buildMobileTopBar() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
    decoration: BoxDecoration(
      color: themeColors.background,
      border: Border(
        bottom: BorderSide(
          color: themeColors.border,
        ),
      ),
    ),
    child: Row(
      children: [
        Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Open menu',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: themeColors.textPrimary,
              ),
            );
          },
        ),

        Expanded(
          child: Text(
            menuItems[selectedMenu],
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notifications'),
        content: const Text(
          'You have no new notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
          },
          icon: Icon(
            Icons.notifications_none,
            color: themeColors.textSecondary,
          ),
        ),

        IconButton(
          tooltip: isDark
              ? 'Switch to light mode'
              : 'Switch to dark mode',
          onPressed: () {
            final currentBrightness =
                Theme.of(context).brightness;

            widget.onThemeChanged(
              currentBrightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: themeColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// SELECTED PAGE
// ============================================================

Widget _buildSelectedPage() {
  switch (selectedMenu) {
    case 0:
      return _buildMainContent();

    case 1:
      return _buildLearningPathPage();

    case 2:
      return _buildSubjectsPage();

    case 3:
      return _buildAiTutorPage();

    case 4:
      return _buildShortRevisionPage();

    case 5:
      return _buildProgressPage();

    case 6:
      return _buildQuizzesPage();

    case 7:
      return _buildSettingsPage();

    default:
      return _buildMainContent();
  }
}

  //PART5
  //PART5
// ============================================================
// DASHBOARD MAIN CONTENT
// ============================================================

Widget _buildMainContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildWelcomeSection(),

      const SizedBox(height: 28),

      _buildContinueLearning(),

      const SizedBox(height: 28),

      _buildLearningPath(),

      const SizedBox(height: 28),

      _buildDashboardLowerSection(),

      const SizedBox(height: 28),

      _buildDashboardBottomSection(),
    ],
  );
}

// ============================================================
// WELCOME SECTION
// ============================================================

Widget _buildWelcomeSection() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double width = constraints.maxWidth;

      // Mobile / narrow layout
      if (width < 800) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 20),
            _buildCurrentSubjectCard(),
            const SizedBox(height: 20),
            _buildProgressCard(),
          ],
        );
      }

      // Desktop layout
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: _buildWelcomeBanner(),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: _buildCurrentSubjectCard(),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: _buildProgressCard(),
          ),
        ],
      );
    },
  );
}

// ============================================================
// WELCOME BANNER
// ============================================================

Widget _buildWelcomeBanner() {
  print('Logged-in gender: ${widget.gender}');
  return Container(
    height: 260,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          LearnRootColors.primary.withOpacity(0.85),
          LearnRootColors.primary.withOpacity(0.45),
        ],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: LearnRootColors.primary.withOpacity(0.35),
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 500;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Welcome back, $_userName!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Continue your learning journey and build stronger concepts every day.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 130,
                  height: 100,
                  child: Image.asset(
                    widget.gender == 'Female'
    ? 'assets/images/student_girl.png'
    : 'assets/images/student_boy.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school_rounded,
                        color: Colors.white70,
                        size: 65,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $_userName!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Continue your learning journey and build stronger concepts every day.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 4,
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: Image.asset(
                    widget.gender == 'Female'
      ? 'assets/images/student_girl.png'
      : 'assets/images/student_boy.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school_rounded,
                        color: Colors.white70,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

// ============================================================
// CURRENT SUBJECT CARD
// ============================================================

Widget _buildCurrentSubjectCard() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    height: 260,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: themeColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: themeColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Subject',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: LearnRootColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.account_tree_outlined,
            color: LearnRootColors.primary,
            size: 28,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Data Structures',
          style: TextStyle(
            color: themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Trees',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubjectScreen(
                    subject: 'Data Structures',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LearnRootColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Continue Learning',
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// PROGRESS CARD
// ============================================================

Widget _buildProgressCard() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    height: 260,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: themeColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: themeColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const Spacer(),

        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: 0.68,
                    strokeWidth: 10,
                    backgroundColor:
                        themeColors.progressTrack,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      LearnRootColors.primary,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '68%',
                      style: TextStyle(
                        color: themeColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: themeColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        Center(
          child: Text(
            'Keep going!',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

  //PART6
// ============================================================
// CONTINUE LEARNING
// ============================================================

Widget _buildContinueLearning() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return _sectionCard(
    title: 'Continue Learning',
    icon: Icons.play_circle_outline,
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubjectScreen(
              subject: 'Data Structures',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? themeColors.card
              : const Color(0xFFF3EEFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark
                ? themeColors.border
                : LearnRootColors.primary.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: LearnRootColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.account_tree_outlined,
                color: LearnRootColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Structures',
                    style: TextStyle(
                      color: themeColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Trees • Binary Trees',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 6,
                    backgroundColor: themeColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      LearnRootColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: themeColors.textSecondary,
              size: 17,
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================================
// LEARNING PATH
// ============================================================

Widget _buildLearningPath() {
  return _sectionCard(
    title: 'Your Learning Path',
    icon: Icons.account_tree_outlined,
    trailing: TextButton(
      onPressed: () {
        setState(() {
          selectedMenu = 1;
        });
      },
      child: const Text(
        'View Full Path',
        style: TextStyle(
          color: LearnRootColors.primary,
        ),
      ),
    ),
    child: Column(
      children: [
        _pathItem(
          'Pointers',
          'Completed',
          Icons.check_circle,
          LearnRootColors.success,
          true,
        ),

        _pathLine(),

        _pathItem(
          'Linked Lists',
          'Completed',
          Icons.check_circle,
          LearnRootColors.success,
          true,
        ),

        _pathLine(),

        _pathItem(
          'Trees',
          'Current Topic',
          Icons.play_circle_fill,
          LearnRootColors.primary,
          true,
        ),

        _pathLine(),

        _pathItem(
          'Graphs',
          'Locked',
          Icons.lock_outline,
          LearnRootColors.textSecondary,
          false,
        ),
      ],
    ),
  );
}

Widget _pathItem(
  String title,
  String subtitle,
  IconData icon,
  Color iconColor,
  bool active,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final Color actualIconColor =
      title == 'Graphs'
          ? themeColors.textSecondary
          : iconColor;

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),
    decoration: BoxDecoration(
      color: active
          ? actualIconColor.withOpacity(0.06)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: actualIconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: actualIconColor,
            size: 21,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: actualIconColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        if (active && title == 'Trees')
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubjectScreen(
                    subject: 'Data Structures',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LearnRootColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text('Continue'),
          ),
      ],
    ),
  );
}

Widget _pathLine() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    margin: const EdgeInsets.only(left: 34),
    width: 2,
    height: 20,
    color: themeColors.border,
  );
}

// ============================================================
// DASHBOARD LOWER SECTION
// ============================================================

Widget _buildDashboardLowerSection() {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 850) {
        return Column(
          children: [
            _buildSubjects(),
            const SizedBox(height: 20),
            _buildAiTutor(),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildSubjects(),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildAiTutor(),
          ),
        ],
      );
    },
  );
}

// ============================================================
// DASHBOARD BOTTOM SECTION
// ============================================================

Widget _buildDashboardBottomSection() {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 850) {
        return Column(
          children: [
            _buildShortRevision(),
            const SizedBox(height: 20),
            _buildStudyGoal(),
            const SizedBox(height: 20),
            _buildRecommendedTopics(),
            const SizedBox(height: 20),
            _buildQuizPerformance(),
          ],
        );
      }

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildShortRevision(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStudyGoal(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRecommendedTopics(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildQuizPerformance(),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  //PART7
  //PART7
// ============================================================
// SUBJECTS
// ============================================================

Widget _buildSubjects() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'Subjects',
    icon: Icons.menu_book_outlined,
    trailing: TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubjectListScreen(),
          ),
        );
      },
      child: const Text(
        'View All',
        style: TextStyle(
          color: LearnRootColors.primary,
        ),
      ),
    ),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectScreen(
                  subject: subjects[index],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 0),
                Icon(
                  subjectIcons[index],
                  color: LearnRootColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    subjects[index],
                    style: TextStyle(
                      color: themeColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ============================================================
// AI TUTOR
// ============================================================

Widget _buildAiTutor() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'AI Tutor',
    icon: Icons.auto_awesome_outlined,
    trailing: TextButton(
      onPressed: () {
        setState(() {
          selectedMenu = 3;
        });
      },
      child: const Text(
        'Open',
        style: TextStyle(
          color: LearnRootColors.primary,
        ),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LearnRootColors.primary.withOpacity(0.18),
            themeColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: LearnRootColors.primary,
            size: 30,
          ),

          const SizedBox(height: 12),

          Text(
            'Need help understanding a topic?',
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Ask the AI Tutor to explain concepts, revise topics or solve your doubts.',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedMenu = 3;
                });
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 18,
              ),
              label: const Text('Ask AI Tutor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LearnRootColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// SHORT REVISION
// ============================================================

Widget _buildShortRevision() {
  return _sectionCard(
    title: 'Short Revision',
    icon: Icons.bolt_outlined,
    trailing: TextButton(
      onPressed: () {
        setState(() {
          selectedMenu = 4;
        });
      },
      child: const Text(
        'View All',
        style: TextStyle(
          color: LearnRootColors.primary,
        ),
      ),
    ),
    child: _buildRevisionSearchBox(),
  );
}

  //PART8
  //PART8
// ============================================================
// STUDY GOAL + RECOMMENDED TOPICS + QUIZ PERFORMANCE
// ============================================================

Widget _buildStudyGoal() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'Study Goal',
    icon: Icons.flag_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Daily Goal',
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '45 / 60 min',
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.75,
            minHeight: 8,
            backgroundColor: themeColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(
              LearnRootColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '15 minutes remaining today',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// RECOMMENDED TOPICS
// ============================================================

Widget _buildRecommendedTopics() {
  return _sectionCard(
    title: 'Recommended Topics',
    icon: Icons.auto_awesome_outlined,
    child: Column(
      children: [
        _recommendedTopic(
          'Pointers',
          'Continue from your current learning path.',
          Icons.code,
        ),
        const SizedBox(height: 12),
        _recommendedTopic(
          'Linked Lists',
          'Recommended based on your progress.',
          Icons.link,
        ),
        const SizedBox(height: 12),
        _recommendedTopic(
          'Binary Trees',
          'Strengthen your data structure concepts.',
          Icons.account_tree_outlined,
        ),
      ],
    ),
  );
}

Widget _recommendedTopic(
  String title,
  String description,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    borderRadius: BorderRadius.circular(13),
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: themeColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: LearnRootColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: themeColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// QUIZ PERFORMANCE
// ============================================================

Widget _buildQuizPerformance() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'Quiz Performance',
    icon: Icons.quiz_outlined,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Average Score',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Text(
              '82%',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: Text(
                'Attempted',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Text(
              '34',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: Text(
                'Best Score',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Text(
              '96%',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  //PART9
  //PART9
  // ============================================================
  // LEARNING PATH PAGE
  // ============================================================

  Widget _buildLearningPathPage() {
    final themeColors = Theme.of(context).extension<LearnRootThemeColors>()!;
    final aliases = _revisionSubjectAliases[_learningPathSubject] ?? [_learningPathSubject];
    final topics = syllabusTopics.where((topic) => aliases.any((alias) =>
        topic.subject.trim().toLowerCase() == alias.trim().toLowerCase())).toList();
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(
          'Learning Path',
          'Follow the prerequisites for your selected subject and continue to the next eligible topic.',
          Icons.account_tree_outlined,
        ),
        const SizedBox(height: 22),
        _sectionCard(
          title: 'Choose Subject',
          icon: Icons.menu_book_outlined,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: themeColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _learningPathSubject,
                isExpanded: true,
                dropdownColor: themeColors.card,
                items: subjects.map((subject) => DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                )).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _learningPathSubject = value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (user == null)
          _infoCard(Icons.login_rounded, 'Sign in to track your path',
              'Your syllabus topics are available, but completion status is saved per signed-in student.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users').doc(user.uid).collection('topicProgress').snapshots(),
            builder: (context, snapshot) {
              final completedIds = <String>{};
              if (snapshot.hasData) {
                for (final doc in snapshot.data!.docs) {
                  final data = doc.data();
                  if (data['status']?.toString() == 'completed') {
                    completedIds.add(doc.id);
                    if (data['topicId'] != null) completedIds.add(data['topicId'].toString());
                  }
                }
              }
              final completedCount = topics.where((t) => completedIds.contains(t.id.toString())).length;
              final ratio = topics.isEmpty ? 0.0 : completedCount / topics.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    title: '$_learningPathSubject Path',
                    icon: Icons.account_tree_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('$completedCount of ${topics.length} topics completed',
                              style: TextStyle(color: themeColors.textSecondary, fontSize: 12))),
                            Text('${(ratio * 100).round()}%',
                              style: const TextStyle(color: LearnRootColors.primary, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: ratio, minHeight: 7,
                            backgroundColor: themeColors.progressBackground,
                            valueColor: const AlwaysStoppedAnimation<Color>(LearnRootColors.primary)),
                        ),
                        const SizedBox(height: 16),
                        if (snapshot.hasError)
                          Text('Could not load saved topic progress.', style: TextStyle(color: themeColors.textSecondary))
                        else if (topics.isEmpty)
                          Text('No syllabus topics were found for this subject.', style: TextStyle(color: themeColors.textSecondary))
                        else
                          ...topics.asMap().entries.map((entry) {
                            final index = entry.key;
                            final topic = entry.value;
                            final topicId = topic.id.toString();
                            final isCompleted = completedIds.contains(topicId);
                            final prerequisites = topic.prerequisites.map((id) => id.toString()).toList();
                            final prerequisiteNames = syllabusTopics
                                .where((item) => prerequisites.contains(item.id.toString()))
                                .map((item) => item.name).toList();
                            final prerequisitesDone = prerequisites.every(completedIds.contains);
                            final eligible = prerequisitesDone;
                            final Color statusColor = isCompleted
                                ? LearnRootColors.success
                                : eligible ? LearnRootColors.primary : themeColors.textSecondary;
                            final status = isCompleted ? 'Completed' : eligible ? 'Ready to learn' : 'Prerequisites pending';
                            return Column(
                              children: [
                                if (index > 0) Divider(height: 1, color: themeColors.border),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38, height: 38,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(11)),
                                        child: Icon(isCompleted ? Icons.check_circle_rounded : eligible ? Icons.play_circle_outline_rounded : Icons.lock_outline_rounded,
                                          color: statusColor, size: 20),
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: InkWell(
                                          onTap: eligible ? () => Navigator.push(context, MaterialPageRoute(
                                            builder: (_) => TopicDetailsScreen(selectedTopic: topic, subject: _learningPathSubject),
                                          )) : null,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(topic.name, style: TextStyle(color: themeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                                              const SizedBox(height: 4),
                                              Text(prerequisiteNames.isEmpty ? status : '$status • Requires ${prerequisiteNames.join(', ')}',
                                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: themeColors.textSecondary, fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isCompleted)
                                        Icon(Icons.check_circle, color: LearnRootColors.success, size: 20)
                                      else if (eligible)
                                        IconButton(
                                          tooltip: 'Mark as completed',
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance.collection('users').doc(user.uid)
                                                .collection('topicProgress').doc(topicId).set({
                                                  'topicId': topicId,
                                                  'topicName': topic.name,
                                                  'subject': _learningPathSubject,
                                                  'status': 'completed',
                                                  'updatedAt': FieldValue.serverTimestamp(),
                                                }, SetOptions(merge: true));
                                            } catch (e) {
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update progress: $e')));
                                            }
                                          },
                                          icon: const Icon(Icons.task_alt_rounded, color: LearnRootColors.primary),
                                        )
                                      else
                                        Icon(Icons.lock_outline_rounded, color: themeColors.textSecondary, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoCard(Icons.lightbulb_outline, 'How your path works',
                    'Topics are listed from your LearnRoot syllabus. Mark a topic completed after studying it; topics requiring that prerequisite will then become eligible.'),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _largePathCard(
    String title,
    String subtitle,
    String status,
    Color color,
    IconData icon,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _largePathConnector() {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(left: 42),
      width: 2,
      height: 24,
      color: themeColors.border,
    );
  }

  //PART10
  //PART10
// ============================================================
// SUBJECTS PAGE
// ============================================================

Widget _buildSubjectsPage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Subjects',
        'Choose a subject and continue your learning.',
        Icons.menu_book_outlined,
      ),

      const SizedBox(height: 25),

      LayoutBuilder(
        builder: (context, constraints) {
          final int columns = constraints.maxWidth < 600 ? 1 : 2;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: columns == 1 ? 3.2 : 2.2,
            ),
            itemBuilder: (context, index) {
              return _subjectPageCard(
                subjects[index],
                subjectIcons[index],
                index,
              );
            },
          );
        },
      ),
    ],
  );
}

Widget _subjectPageCard(
  String subject,
  IconData icon,
  int index,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final List<String> progress = [
    '72%',
    '68%',
    '45%',
    '32%',
    '51%',
    '25%',
  ];

  final double value =
      double.tryParse(progress[index].replaceAll('%', ''))! /
          100;

  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectScreen(
            subject: subject,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF3EEFF)
            : themeColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? LearnRootColors.primary.withOpacity(0.10)
              : themeColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      LearnRootColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: LearnRootColors.primary,
                  size: 25,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.arrow_forward_ios,
                color: themeColors.textSecondary,
                size: 15,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            subject,
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '${progress[index]} completed',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: themeColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                LearnRootColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  //PART11
  //PART11
// ============================================================
// AI TUTOR PAGE
// ============================================================

Widget _buildAiTutorPage() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;
  final scheme = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'AI Tutor',
        'Ask doubts and get clear, topic-focused help.',
        Icons.auto_awesome_outlined,
      ),

      const SizedBox(height: 25),

      _sectionCard(
        title: 'AI Doubt Solver',
        icon: Icons.forum_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you stuck on?',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Enter the topic and ask your doubt. LearnRoot will explain it in simple words.',
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: _aiTopicController,
              style: TextStyle(
                color: themeColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Topic',
                hintText: 'e.g. Pointers',
                prefixIcon: Icon(
                  Icons.menu_book_outlined,
                  color: LearnRootColors.primary,
                ),
                labelStyle: TextStyle(
                  color: themeColors.textSecondary,
                ),
                hintStyle: TextStyle(
                  color: themeColors.textSecondary,
                ),
                filled: true,
                fillColor: themeColors.inputBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: LearnRootColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _aiDoubtController,
              minLines: 3,
              maxLines: 6,
              style: TextStyle(
                color: themeColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Your doubt',
                hintText: 'Ask anything about this topic...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 52),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: LearnRootColors.primary,
                  ),
                ),
                labelStyle: TextStyle(
                  color: themeColors.textSecondary,
                ),
                hintStyle: TextStyle(
                  color: themeColors.textSecondary,
                ),
                filled: true,
                fillColor: themeColors.inputBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: LearnRootColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDoubtPrompt(
                  'Explain simply',
                  'Explain this topic in very simple words.',
                ),
                _buildDoubtPrompt(
                  'Give an example',
                  'Explain this topic with a simple example.',
                ),
                _buildDoubtPrompt(
                  'Common mistake',
                  'What is a common mistake students make in this topic?',
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAskingDoubt ? null : _askDashboardDoubt,
                icon: _isAskingDoubt
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isAskingDoubt ? 'Thinking...' : 'Ask AI',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LearnRootColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      if (_aiDoubtAnswer != null) ...[
        const SizedBox(height: 18),
        _sectionCard(
          title: 'AI Tutor Answer',
          icon: Icons.lightbulb_outline_rounded,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: themeColors.border,
              ),
            ),
            child: SelectableText(
              _aiDoubtAnswer!,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],

      const SizedBox(height: 18),

      _sectionCard(
        title: 'How to use AI Tutor',
        icon: Icons.tips_and_updates_outlined,
        child: Column(
          children: [
            _buildTutorTip(
              '1',
              'Choose a topic',
              'Enter the topic you are currently studying.',
            ),
            const SizedBox(height: 10),
            _buildTutorTip(
              '2',
              'Ask your doubt',
              'Describe exactly what you do not understand.',
            ),
            const SizedBox(height: 10),
            _buildTutorTip(
              '3',
              'Learn and follow up',
              'Read the explanation and ask another doubt when needed.',
            ),
          ],
        ),
      ),
    ],
  );
}

Future<void> _askDashboardDoubt() async {
  final topic = _aiTopicController.text.trim();
  final question = _aiDoubtController.text.trim();

  if (topic.isEmpty || question.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter both a topic and your doubt.'),
      ),
    );
    return;
  }

  setState(() {
    _isAskingDoubt = true;
    _aiDoubtAnswer = null;
  });

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/doubt'),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topic,
        'question': question,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        _aiDoubtAnswer =
            decoded['answer']?.toString() ?? 'No answer was returned.';
        _isAskingDoubt = false;
      });
    } else {
      setState(() {
        _aiDoubtAnswer =
            'Unable to solve the doubt. Server returned status code ${response.statusCode}.';
        _isAskingDoubt = false;
      });
    }
  } catch (_) {
    if (!mounted) return;
    setState(() {
      _aiDoubtAnswer =
          'Could not connect to the AI Tutor. Make sure the Flask backend is running on port 5000.';
      _isAskingDoubt = false;
    });
  }
}


Widget _buildDoubtPrompt(String label, String question) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    onTap: () {
      setState(() {
        _aiDoubtController.text = question;
      });
    },
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: LearnRootColors.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LearnRootColors.primary.withOpacity(0.20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: LearnRootColors.primary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget _buildTutorTip(
  String number,
  String title,
  String description,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: themeColors.background,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: themeColors.border,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LearnRootColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: LearnRootColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  //PART12
// ============================================================
// SHORT REVISION PAGE
// ============================================================

Widget _buildShortRevisionPage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Short Revision',
        'Choose a LearnRoot subject and search its topics for a one-shot revision.',
        Icons.bolt_outlined,
      ),

      const SizedBox(height: 25),

      _sectionCard(
        title: 'One-Shot Revision',
        icon: Icons.flash_on_outlined,
        child: _buildRevisionSearchBox(),
      ),

      const SizedBox(height: 18),

      _sectionCard(
        title: 'How it works',
        icon: Icons.lightbulb_outline_rounded,
        child: Text(
          'Select a subject, search one of its actual LearnRoot syllabus topics, and open a focused one-shot revision sheet. The generated revision is cached in MySQL for reuse.',
          style: TextStyle(
            color: Theme.of(context)
                .extension<LearnRootThemeColors>()!
                .textSecondary,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

  //PART13
  // ============================================================
// PART 13 — PROGRESS PAGE
// ============================================================

Widget _buildProgressPage() {
  final themeColors = Theme.of(context).extension<LearnRootThemeColors>()!;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeader('Progress', 'Track your actual learning activity.', Icons.bar_chart_outlined),
      const SizedBox(height: 22),
      _infoCard(Icons.login_rounded, 'Sign in to see your progress', 'Quiz attempts and completed topics are saved to your student account.'),
    ]);
  }

  final topicStream = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('topicProgress').snapshots();
  final quizStream = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('quizAttempts').orderBy('createdAt', descending: true).snapshots();

  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: topicStream,
    builder: (context, topicSnapshot) {
      final completed = <String>{};
      if (topicSnapshot.hasData) {
        for (final doc in topicSnapshot.data!.docs) {
          final data = doc.data();
          if (data['status']?.toString() == 'completed') {
            completed.add(doc.id);
            if (data['topicId'] != null) completed.add(data['topicId'].toString());
          }
        }
      }
      final allTotal = syllabusTopics.length;
      final overall = allTotal == 0 ? 0.0 : (syllabusTopics.where((t) => completed.contains(t.id.toString())).length / allTotal);

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: quizStream,
        builder: (context, quizSnapshot) {
          final attempts = quizSnapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          final percentages = attempts.map((doc) => (doc.data()['percentage'] as num?)?.toDouble()).whereType<double>().toList();
          final average = percentages.isEmpty ? 0.0 : percentages.reduce((a, b) => a + b) / percentages.length;
          final latest = attempts.isEmpty ? null : attempts.first.data();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader('Progress', 'Your learning statistics update from saved quiz attempts and topic completion.', Icons.bar_chart_outlined),
              const SizedBox(height: 22),
              LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 720;
                final cards = [
                  _analyticsCard(title: 'Syllabus completed', value: '${(overall * 100).round()}%', subtitle: '${syllabusTopics.where((t) => completed.contains(t.id.toString())).length} of $allTotal topics', icon: Icons.account_tree_outlined, fraction: overall),
                  _analyticsCard(title: 'Quizzes attempted', value: '${attempts.length}', subtitle: 'Saved attempts', icon: Icons.quiz_outlined),
                  _analyticsCard(title: 'Average quiz score', value: percentages.isEmpty ? '—' : '${average.round()}%', subtitle: percentages.isEmpty ? 'Complete a quiz to start tracking' : 'Across ${percentages.length} attempts', icon: Icons.trending_up_rounded),
                ];
                if (narrow) return Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card)).toList());
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: card))).toList());
              }),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Subject Progress', icon: Icons.menu_book_outlined,
                child: Column(children: subjects.map((subject) {
                  final aliases = _revisionSubjectAliases[subject] ?? [subject];
                  final subjectTopics = syllabusTopics.where((t) => aliases.any((alias) => alias.toLowerCase() == t.subject.trim().toLowerCase())).toList();
                  final done = subjectTopics.where((t) => completed.contains(t.id.toString())).length;
                  final value = subjectTopics.isEmpty ? 0.0 : done / subjectTopics.length;
                  final subjectAttempts = attempts.where((doc) => (doc.data()['subject']?.toString() ?? '').toLowerCase() == subject.toLowerCase()).toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(subject, style: TextStyle(color: themeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13))), Text('${(value * 100).round()}%', style: TextStyle(color: themeColors.textSecondary, fontSize: 12))]),
                      const SizedBox(height: 7),
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: value, minHeight: 7, backgroundColor: themeColors.progressBackground, valueColor: const AlwaysStoppedAnimation<Color>(LearnRootColors.primary))),
                      const SizedBox(height: 4),
                      Text('$done/${subjectTopics.length} topics completed • ${subjectAttempts.length} quiz attempts', style: TextStyle(color: themeColors.textSecondary, fontSize: 11)),
                    ]),
                  );
                }).toList()),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Recent Quiz Activity', icon: Icons.history_rounded,
                child: quizSnapshot.connectionState == ConnectionState.waiting && !quizSnapshot.hasData
                    ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                    : attempts.isEmpty
                        ? Text('No saved quiz attempts yet. Complete a quiz to see your score and topic here.', style: TextStyle(color: themeColors.textSecondary, fontSize: 13, height: 1.5))
                        : Column(children: attempts.take(5).map((doc) {
                            final data = doc.data();
                            final score = (data['percentage'] as num?)?.round();
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(backgroundColor: Color(0x1A6C63FF), child: Icon(Icons.quiz_outlined, color: LearnRootColors.primary)),
                              title: Text(data['topicName']?.toString() ?? data['topic']?.toString() ?? 'Quiz', style: TextStyle(color: themeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                              subtitle: Text(data['subject']?.toString() ?? 'Subject not recorded', style: TextStyle(color: themeColors.textSecondary, fontSize: 11)),
                              trailing: Text(score == null ? 'Saved' : '$score%', style: TextStyle(color: score != null && score >= 70 ? LearnRootColors.success : LearnRootColors.primary, fontWeight: FontWeight.w800)),
                            );
                          }).toList()),
              ),
              if (topicSnapshot.hasError || quizSnapshot.hasError) ...[
                const SizedBox(height: 10),
                Text('Some progress data could not be loaded. Check your Firestore rules and connection.', style: TextStyle(color: themeColors.textSecondary, fontSize: 11)),
              ],
              if (latest != null && (latest['percentage'] as num? ?? 0) < 60) ...[
                const SizedBox(height: 14),
                _infoCard(Icons.lightbulb_outline_rounded, 'Suggested next step', 'Your latest quiz result suggests revising ${latest['topicName'] ?? latest['topic'] ?? 'that topic'} before moving forward.'),
              ],
            ],
          );
        },
      );
    },
  );
}

Widget _analyticsCard({required String title, required String value, required String subtitle, required IconData icon, double? fraction}) {
  final themeColors = Theme.of(context).extension<LearnRootThemeColors>()!;
  return _sectionCard(
    title: title, icon: icon,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: themeColors.textPrimary, fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(subtitle, style: TextStyle(color: themeColors.textSecondary, fontSize: 11, height: 1.35)),
      if (fraction != null) ...[
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: fraction, minHeight: 7, backgroundColor: themeColors.progressBackground, valueColor: const AlwaysStoppedAnimation<Color>(LearnRootColors.primary))),
      ],
    ]),
  );
}

// ============================================================
// OVERALL PROGRESS CARD
// ============================================================

Widget _progressOverviewCard() {
  final themeColors =
      Theme.of(context)
          .extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'Overall Progress',
    icon: Icons.trending_up,
    child: Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 115,
                height: 115,
                child: CircularProgressIndicator(
                  value: 0.64,
                  strokeWidth: 10,
                  backgroundColor:
                      themeColors.progressBackground,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    LearnRootColors.primary,
                  ),
                ),
              ),

              Text(
                '64%',
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 22),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Great progress!',
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Keep learning consistently to reach your goals.',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// STUDY TIME CARD
// ============================================================

Widget _studyTimeCard() {
  final themeColors =
      Theme.of(context)
          .extension<LearnRootThemeColors>()!;

  return _sectionCard(
    title: 'Study Time',
    icon: Icons.access_time,
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '18 hours',
          style: TextStyle(
            color: themeColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'This month',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 20),

        LinearProgressIndicator(
          value: 0.72,
          minHeight: 8,
          backgroundColor:
              themeColors.progressBackground,
          valueColor:
              const AlwaysStoppedAnimation<Color>(
            LearnRootColors.success,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// SUBJECT PROGRESS
// ============================================================

Widget _progressSubject(
  String title,
  double value,
) {
  final themeColors =
      Theme.of(context)
          .extension<LearnRootThemeColors>()!;

  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '${(value * 100).round()}%',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      ClipRRect(
        borderRadius:
            BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 7,
          backgroundColor:
              themeColors.progressBackground,
          valueColor:
              const AlwaysStoppedAnimation<Color>(
            LearnRootColors.primary,
          ),
        ),
      ),
    ],
  );
}

  //PART14
  //PART14
// ============================================================
// QUIZZES PAGE
// ============================================================

String _quizSubject = 'C Programming';
String _quizTopic = '';

final Map<String, List<String>> _quizSubjectAliases = const {
  'C Programming': ['C Programming'],
  'Data Structures': ['Data Structures'],
  'OOP Java': ['OOP Java', 'OOPs – Java', 'OOPs - Java'],
  'Computer Networks': ['Computer Networks'],
  'Operating System': ['Operating System', 'Operating Systems'],
  'DBMS': ['DBMS'],
};

List<Topic> _quizTopicsForSubject(String subject) {
  final aliases = _quizSubjectAliases[subject] ?? [subject];

  return syllabusTopics
      .where((topic) => aliases.contains(topic.subject))
      .toList();
}

void _selectQuizSubject(String? subject) {
  if (subject == null || subject.isEmpty) return;

  setState(() {
    _quizSubject = subject;
    _quizTopic = '';
  });
}

Future<void> _openQuizTopicPicker() async {
  final topics = _quizTopicsForSubject(_quizSubject);
  String query = '';

  final selected = await showDialog<Topic>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredTopics = topics.where((topic) {
            return topic.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

          final themeColors =
              Theme.of(context).extension<LearnRootThemeColors>()!;

          return AlertDialog(
            backgroundColor: themeColors.card,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
            contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            title: Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: LearnRootColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Select Quiz Topic',
                    style: TextStyle(
                      color: themeColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: Icon(
                    Icons.close_rounded,
                    color: themeColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeColors.border),
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setDialogState(() {
                          query = value;
                        });
                      },
                      style: TextStyle(
                        color: themeColors.textPrimary,
                        fontSize: 13,
                      ),
                      cursorColor: LearnRootColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search topics in $_quizSubject...',
                        hintStyle: TextStyle(
                          color: themeColors.textSecondary,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: themeColors.textSecondary,
                          size: 19,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: filteredTopics.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No matching topics found.',
                                  style: TextStyle(
                                    color: themeColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredTopics.length,
                              separatorBuilder: (_, __) =>
                                  Divider(
                                    height: 1,
                                    color: themeColors.border,
                                  ),
                              itemBuilder: (context, index) {
                                final topic = filteredTopics[index];

                                return ListTile(
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  leading: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: LearnRootColors.primary
                                          .withValues(alpha: 0.10),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_outlined,
                                      color: LearnRootColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    topic.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: themeColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: themeColors.textSecondary,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    Navigator.pop(dialogContext, topic);
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (selected == null || !mounted) return;

  setState(() {
    _quizTopic = selected.name;
  });
}

void _startQuiz() {
  final topicName = _quizTopic.trim();

  if (topicName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a topic for the quiz.'),
      ),
    );
    return;
  }

  final topics = _quizTopicsForSubject(_quizSubject);
  Topic? selectedTopic;

  for (final topic in topics) {
    if (topic.name.toLowerCase() == topicName.toLowerCase()) {
      selectedTopic = topic;
      break;
    }
  }

  final chosenTopic = selectedTopic;
  if (chosenTopic == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please choose a topic from $_quizSubject.'),
      ),
    );
    return;
  }

  final topicIndex = topics.indexOf(chosenTopic);

  final module4Topic = module4.Module4Topic(
    topicId: topicIndex < 0 ? 0 : topicIndex,
    topicName: chosenTopic.name,
    subject: _quizSubject,
    topicOrder: topicIndex < 0 ? 0 : topicIndex,
    topicCode: chosenTopic.id,
    completed: false,
  );

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => module4_quiz.QuizScreen(
        topic: module4Topic,
      ),
    ),
  );
}

Widget _buildQuizzesPage() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Quizzes',
        'Test your knowledge with AI-generated topic quizzes.',
        Icons.quiz_outlined,
      ),

      const SizedBox(height: 25),

      _sectionCard(
        title: 'AI Quiz',
        icon: Icons.auto_awesome_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a LearnRoot subject and choose any topic from its syllabus.',
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Select Subject',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 760),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: themeColors.inputBackground,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: themeColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _quizSubject,
                  isExpanded: true,
                  dropdownColor: themeColors.inputBackground,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: themeColors.textSecondary,
                  ),
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  items: subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: _selectQuizSubject,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Select Topic',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Search and select any topic from the selected subject.',
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: _openQuizTopicPicker,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 760),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: themeColors.inputBackground,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: themeColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: themeColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _quizTopic.isEmpty
                            ? 'Search or select a topic...'
                            : _quizTopic,
                        style: TextStyle(
                          color: _quizTopic.isEmpty
                              ? themeColors.textSecondary
                              : themeColors.textPrimary,
                          fontSize: 13,
                          fontWeight: _quizTopic.isEmpty
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: themeColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: const Text('Start AI Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LearnRootColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 18),

      _sectionCard(
        title: 'How it works',
        icon: Icons.lightbulb_outline_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _quizInfoRow(
              Icons.menu_book_outlined,
              'Choose a subject',
              'Your topics come directly from the LearnRoot syllabus.',
            ),
            const SizedBox(height: 14),
            _quizInfoRow(
              Icons.search_rounded,
              'Choose a topic',
              'Search through the complete topic list for that subject.',
            ),
            const SizedBox(height: 14),
            _quizInfoRow(
              Icons.auto_awesome_rounded,
              'Start the quiz',
              'The existing AI quiz screen generates questions for the selected topic.',
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _quizInfoRow(
  IconData icon,
  String title,
  String description,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LearnRootColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: LearnRootColors.primary,
          size: 19,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  
//PART15
// ============================================================
// SETTINGS PAGE
// ============================================================

Widget _buildSettingsPage() {
  final themeColors = Theme.of(context).extension<LearnRootThemeColors>()!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final user = FirebaseAuth.instance.currentUser;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader('Settings', 'Personalize your LearnRoot experience.', Icons.settings_outlined),
      const SizedBox(height: 22),
      _sectionCard(
        title: 'Learning Preferences', icon: Icons.tune_rounded,
        child: Column(children: [
          _settingItem('Daily Study Goal', _settingsLoading ? 'Loading…' : '${_dailyGoalMinutes} minutes per day', Icons.flag_outlined, onTap: _settingsLoading ? () {} : _chooseDailyGoal),
          Divider(color: themeColors.border, height: 22),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: LearnRootColors.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.notifications_active_outlined, color: LearnRootColors.primary)),
            title: Text('Learning Reminders', style: TextStyle(color: themeColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(_notificationsEnabled ? 'Preference enabled' : 'Preference disabled', style: TextStyle(color: themeColors.textSecondary, fontSize: 11)),
            trailing: Switch(value: _notificationsEnabled, onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _saveUserPreferences({'notificationsEnabled': value});
            }),
          ),
          Divider(color: themeColors.border, height: 22),
          _settingItem('Preferred Learning Style', _preferredLearningStyle, Icons.psychology_outlined, onTap: _chooseLearningStyle),
          Divider(color: themeColors.border, height: 22),
          _settingItem('Appearance', isDark ? 'Dark mode' : 'Light mode', isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, onTap: () async {
            final next = isDark ? ThemeMode.light : ThemeMode.dark;
            widget.onThemeChanged(next);
            await _saveUserPreferences({'themeMode': next == ThemeMode.dark ? 'dark' : 'light'});
          }),
        ]),
      ),
      const SizedBox(height: 18),
      _sectionCard(
        title: 'Account', icon: Icons.person_outline_rounded,
        child: Column(children: [
          _settingItem('Profile', 'View and edit your profile', Icons.person_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          }),
          Divider(color: themeColors.border, height: 22),
          _settingItem('Signed in as', user?.email ?? 'Guest account', Icons.verified_user_outlined, onTap: () {}),
          Divider(color: themeColors.border, height: 22),
          _settingItem('Sign out', 'Sign out of this LearnRoot account', Icons.logout_rounded, onTap: _confirmSignOut),
        ]),
      ),
      const SizedBox(height: 14),
      _infoCard(Icons.info_outline_rounded, 'About your preferences',
        _settingsLoading ? 'Loading your saved preferences…' : user == null
          ? 'Preferences work for this session. Sign in to save them to your account.'
          : 'Your preferences are saved to your signed-in student profile. Reminder scheduling is not enabled by this switch alone.'),
    ],
  );
}

Widget _settingItem(
  String title,
  String subtitle,
  IconData icon, {
  required VoidCallback onTap,
}) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: LearnRootColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right,
            color: themeColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}

   //PART16
// ============================================================
// PART 16 — COMMON UI HELPERS
// ============================================================

// ============================================================
// SECTION CARD
// ============================================================

Widget _sectionCard({
  required String title,
  required IconData icon,
  required Widget child,
  Widget? trailing,
}) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: themeColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: LearnRootColors.primary,
              size: 21,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (trailing != null)
              trailing,
          ],
        ),

        const SizedBox(height: 18),

        child,
      ],
    ),
  );
}

// ============================================================
// PAGE HEADER
// ============================================================

Widget _pageHeader(
  String title,
  String subtitle,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: LearnRootColors.primary.withOpacity(0.13),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: LearnRootColors.primary,
          size: 25,
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ============================================================
// INFO CARD
// ============================================================

Widget _infoCard(
  IconData icon,
  String title,
  String description,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: themeColors.cardSecondary,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: themeColors.border,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: LearnRootColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: LearnRootColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}