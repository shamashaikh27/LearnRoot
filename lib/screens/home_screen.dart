//PART1
// ============================================================
// IMPORTS, HOME SCREEN AND VARIABLES
// ============================================================
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'subject_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('registered_name');

    if (!mounted) return;

    print('Saved name: $savedName');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _userName = savedName;
      });
    }
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
        setState(() {
          selectedMenu = 2;
        });
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
    child: Column(
      children: [
        _revisionItem(
          'Binary Tree',
          '5 min revision',
          Icons.account_tree_outlined,
        ),
        const SizedBox(height: 10),
        _revisionItem(
          'Pointers',
          '7 min revision',
          Icons.code,
        ),
        const SizedBox(height: 10),
        _revisionItem(
          'Linked Lists',
          '6 min revision',
          Icons.link,
        ),
      ],
    ),
  );
}

Widget _revisionItem(
  String title,
  String subtitle,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.12),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
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
            Icons.play_arrow_rounded,
            color: themeColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    ),
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
              color: LearnRootColors.primary.withOpacity(0.12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(
          'Learning Path',
          'Follow your prerequisite-based learning journey.',
          Icons.account_tree_outlined,
        ),

        const SizedBox(height: 25),

        _sectionCard(
          title: 'Data Structures Path',
          icon: Icons.account_tree_outlined,
          child: Column(
            children: [
              _largePathCard(
                'Pointers',
                'Foundation',
                'Completed',
                LearnRootColors.success,
                Icons.code,
              ),

              _largePathConnector(),

              _largePathCard(
                'Linked Lists',
                'Prerequisite completed',
                'Completed',
                LearnRootColors.success,
                Icons.link,
              ),

              _largePathConnector(),

              _largePathCard(
                'Trees',
                'Current topic',
                'In Progress',
                LearnRootColors.primary,
                Icons.account_tree_outlined,
              ),

              _largePathConnector(),

              _largePathCard(
                'Graphs',
                'Requires Trees',
                'Locked',
                LearnRootColors.textSecondary,
                Icons.hub_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        _infoCard(
          Icons.lightbulb_outline,
          'Learning tip',
          'Complete prerequisite topics before moving to advanced concepts. This helps build a stronger learning foundation.',
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
                      LearnRootColors.primary.withOpacity(0.12),
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

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'AI Tutor',
        'Your intelligent learning assistant.',
        Icons.auto_awesome_outlined,
      ),

      const SizedBox(height: 25),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    LearnRootColors.primary.withOpacity(0.20),
                    themeColors.card,
                  ]
                : [
                    const Color(0xFFEDE5FF),
                    const Color(0xFFF7F3FF),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LearnRootColors.primary.withOpacity(
              isDark ? 0.25 : 0.15,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: LearnRootColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: LearnRootColors.primary,
                size: 29,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'How can I help you learn?',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'AI-powered explanations, revisions and recommendations will appear here.',
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 22),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _aiActionChip(
                  'Explain a Topic',
                  Icons.lightbulb_outline,
                ),
                _aiActionChip(
                  'Short Revision',
                  Icons.bolt_outlined,
                ),
                _aiActionChip(
                  'Recommended Topics',
                  Icons.recommend_outlined,
                ),
                _aiActionChip(
                  'Ask a Doubt',
                  Icons.help_outline,
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 25),

      _sectionCard(
        title: 'Recommended for You',
        icon: Icons.recommend_outlined,
        child: Column(
          children: [
            _recommendationItem(
              'Binary Search Trees',
              'Continue from your current learning path',
              Icons.account_tree_outlined,
            ),

            const SizedBox(height: 10),

            _recommendationItem(
              'Graph Basics',
              'Prepare for your upcoming topic',
              Icons.hub_outlined,
            ),
          ],
        ),
      ),
    ],
  );
}

// ============================================================
// AI ACTION CHIP
// ============================================================

Widget _aiActionChip(
  String title,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: LearnRootColors.primary,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// RECOMMENDATION ITEM
// ============================================================

Widget _recommendationItem(
  String title,
  String subtitle,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: LearnRootColors.primary,
              size: 22,
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
            size: 20,
          ),
        ],
      ),
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
        'Quickly revise important concepts.',
        Icons.bolt_outlined,
      ),

      const SizedBox(height: 25),

      _revisionLargeCard(
        'Pointers',
        'Quick revision of pointer fundamentals.',
        '7 min',
        Icons.code,
      ),

      const SizedBox(height: 15),

      _revisionLargeCard(
        'Linked Lists',
        'Revise nodes, insertion and deletion.',
        '6 min',
        Icons.link,
      ),

      const SizedBox(height: 15),

      _revisionLargeCard(
        'Binary Trees',
        'Revise tree structure and traversal basics.',
        '5 min',
        Icons.account_tree_outlined,
      ),

      const SizedBox(height: 15),

      _revisionLargeCard(
        'Graphs',
        'Quick introduction to graph concepts.',
        '8 min',
        Icons.hub_outlined,
      ),
    ],
  );
}

Widget _revisionLargeCard(
  String title,
  String description,
  String duration,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(17),
    child: Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark
            ? themeColors.card
            : const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isDark
              ? themeColors.border
              : LearnRootColors.primary.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: LearnRootColors.primary,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
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
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                color: LearnRootColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  //PART13
  // ============================================================
// PART 13 — PROGRESS PAGE
// ============================================================

Widget _buildProgressPage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Progress',
        'Track your learning journey and achievements.',
        Icons.bar_chart_outlined,
      ),

      const SizedBox(height: 25),

      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              children: [
                _progressOverviewCard(),

                const SizedBox(height: 18),

                _studyTimeCard(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _progressOverviewCard(),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _studyTimeCard(),
              ),
            ],
          );
        },
      ),

      const SizedBox(height: 22),

      _sectionCard(
        title: 'Subject Progress',
        icon: Icons.menu_book_outlined,
        child: Column(
          children: [
            _progressSubject(
              'C Programming',
              0.72,
            ),

            const SizedBox(height: 18),

            _progressSubject(
              'Data Structures',
              0.68,
            ),

            const SizedBox(height: 18),

            _progressSubject(
              'OOP Java',
              0.45,
            ),

            const SizedBox(height: 18),

            _progressSubject(
              'Computer Networks',
              0.32,
            ),

            const SizedBox(height: 18),

            _progressSubject(
              'Operating System',
              0.51,
            ),

            const SizedBox(height: 18),

            _progressSubject(
              'DBMS',
              0.25,
            ),
          ],
        ),
      ),
    ],
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

Widget _buildQuizzesPage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Quizzes',
        'Test your knowledge and track your performance.',
        Icons.quiz_outlined,
      ),

      const SizedBox(height: 25),

      _quizCard(
        'C Programming Basics',
        '10 Questions',
        '82%',
        Icons.code,
      ),

      const SizedBox(height: 15),

      _quizCard(
        'Data Structures',
        '15 Questions',
        '88%',
        Icons.account_tree_outlined,
      ),

      const SizedBox(height: 15),

      _quizCard(
        'Object Oriented Programming',
        '10 Questions',
        '76%',
        Icons.code_rounded,
      ),

      const SizedBox(height: 15),

      _quizCard(
        'Computer Networks',
        '12 Questions',
        'Coming Soon',
        Icons.lan_outlined,
      ),
    ],
  );
}

Widget _quizCard(
  String title,
  String questions,
  String score,
  IconData icon,
) {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  final bool available = score != 'Coming Soon';

  return Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: isDark
          ? themeColors.card
          : const Color(0xFFF3EEFF),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: isDark
            ? themeColors.border
            : LearnRootColors.primary.withOpacity(0.10),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: LearnRootColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: LearnRootColors.primary,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                questions,
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        if (available)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: const TextStyle(
                  color: LearnRootColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Best Score',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          )
        else
          Text(
            'Coming Soon',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 11,
            ),
          ),
      ],
    ),
  );
}

  //PART15
// ============================================================
// SETTINGS PAGE
// ============================================================

Widget _buildSettingsPage() {
  final themeColors =
      Theme.of(context).extension<LearnRootThemeColors>()!;

  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeader(
        'Settings',
        'Manage your LearnRoot preferences.',
        Icons.settings_outlined,
      ),

      const SizedBox(height: 25),

      _sectionCard(
        title: 'Learning Preferences',
        icon: Icons.tune_outlined,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.transparent
                : const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _settingItem(
                'Daily Study Goal',
                '1 hour per day',
                Icons.flag_outlined,
                onTap: () {
                     showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Learning Preferences'),
                            content: const Text(
                              'Customize your learning experience and study preferences.',
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
              ),

              Divider(
                color: themeColors.border,
                height: 25,
              ),

              _settingItem(
                'Learning Reminders',
                'Enabled',
                Icons.notifications_none,
                onTap: () {},
              ),

              Divider(
                color: themeColors.border,
                height: 25,
              ),

              _settingItem(
                'Preferred Learning Style',
                'Visual',
                Icons.palette_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),

      _sectionCard(
        title: 'Account',
        icon: Icons.person_outline,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.transparent
                : const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _settingItem(
                'Profile',
                'View and edit your profile',
                Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),

              Divider(
                color: themeColors.border,
                height: 25,
              ),

              _settingItem(
                'Notifications',
                'Manage notifications',
                Icons.notifications_none,
                onTap: () {
                  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notifications'),
        content: const Text(
          'Manage your notification preferences and updates.',
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
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),

      _infoCard(
        Icons.info_outline,
        'LearnRoot',
        'Your personalized learning dashboard for structured and consistent learning.',
      ),
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
            color: LearnRootColors.primary.withOpacity(0.12),
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