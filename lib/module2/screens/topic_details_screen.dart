import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';
import 'graph_screen.dart';

class TopicDetailsScreen extends StatelessWidget {
  final Topic selectedTopic;
  final String subject;

  const TopicDetailsScreen({
    super.key,
    required this.selectedTopic,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    final secondarySurface = isDark
        ? AppTheme.darkSecondary
        : AppTheme.lightSecondary;

    final cardColor = isDark
        ? AppTheme.darkCard
        : AppTheme.lightCard;

    final borderColor = isDark
        ? const Color(0xFF222D50)
        : const Color(0xFFE8E6F0);

    final mainText = isDark
        ? AppTheme.darkMainText
        : AppTheme.lightMainText;

    final secondaryText = isDark
        ? AppTheme.darkSecondaryText
        : AppTheme.lightSecondaryText;

    final prerequisites = syllabusTopics
        .where(
          (topic) =>
              selectedTopic.prerequisites.contains(topic.id),
        )
        .toList();

    final usedInTopics = syllabusTopics
        .where(
          (topic) =>
              topic.prerequisites.contains(selectedTopic.id),
        )
        .toList();

    return Scaffold(
      backgroundColor: backgroundColor,

      // =========================================================
      // APP BAR
      // =========================================================
      //
      // The title "Explore Topic" has intentionally been removed.
      // This prevents it from staying fixed while scrolling.
      //
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_rounded,
            color: mainText,
            size: 23,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        // No Explore Topic title here.
        title: const SizedBox.shrink(),

        actions: [
          IconButton(
            tooltip: 'Bookmark',
            icon: Icon(
              Icons.bookmark_border_rounded,
              color: mainText,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: secondarySurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    'Bookmark feature coming later.',
                    style: TextStyle(
                      color: mainText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CURRENT TOPIC HEADER
                  // =================================================

                  _buildTopicHeader(
                    isDark: isDark,
                    secondarySurface: secondarySurface,
                    mainText: mainText,
                    secondaryText: secondaryText,
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // AI LEARNING
                  // =================================================

                  _buildSectionHeader(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Learning',
                    subtitle:
                        'Learn this topic with intelligent AI-powered tools.',
                    count: '4 Tools',
                    mainText: mainText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 14),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildExploreCard(
                                isDark: isDark,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                mainText: mainText,
                                secondaryText: secondaryText,
                                icon:
                                    Icons.auto_awesome_rounded,
                                title: 'AI Summary',
                                subtitle:
                                    'Get a simple and concise summary of this topic.',
                                iconBackground:
                                    AppTheme.primaryPurple,
                                iconColor: Colors.white,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Summary',
                                    isDark,
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildExploreCard(
                                isDark: isDark,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                mainText: mainText,
                                secondaryText: secondaryText,
                                icon:
                                    Icons.chat_bubble_rounded,
                                title: 'AI Doubt Solver',
                                subtitle:
                                    'Ask questions and clear your doubts with AI.',
                                iconBackground:
                                    secondarySurface,
                                iconColor:
                                    AppTheme.primaryPurple,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Doubt Solver',
                                    isDark,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            children: [
                              _buildExploreCard(
                                isDark: isDark,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                mainText: mainText,
                                secondaryText: secondaryText,
                                icon:
                                    Icons.auto_graph_rounded,
                                title:
                                    'AI Visual Explanation',
                                subtitle:
                                    'Understand concepts through visual explanations.',
                                iconBackground:
                                    secondarySurface,
                                iconColor:
                                    AppTheme.gradientPurpleEnd,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Visual Explanation',
                                    isDark,
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildExploreCard(
                                isDark: isDark,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                mainText: mainText,
                                secondaryText: secondaryText,
                                icon:
                                    Icons.warning_amber_rounded,
                                title: 'What If I Skip?',
                                subtitle:
                                    'See how skipping this topic can affect future learning.',
                                iconBackground:
                                    secondarySurface,
                                iconColor:
                                    AppTheme.warningOrange,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'What If I Skip?',
                                    isDark,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI Summary',
                          subtitle:
                              'Get a simple and concise summary of this topic.',
                          iconBackground:
                              AppTheme.primaryPurple,
                          iconColor: Colors.white,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Summary',
                              isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon: Icons.auto_graph_rounded,
                          title: 'AI Visual Explanation',
                          subtitle:
                              'Understand concepts through visual explanations.',
                          iconBackground: secondarySurface,
                          iconColor:
                              AppTheme.gradientPurpleEnd,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Visual Explanation',
                              isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon: Icons.chat_bubble_rounded,
                          title: 'AI Doubt Solver',
                          subtitle:
                              'Ask questions and clear your doubts with AI.',
                          iconBackground: secondarySurface,
                          iconColor:
                              AppTheme.primaryPurple,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Doubt Solver',
                              isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon:
                              Icons.warning_amber_rounded,
                          title: 'What If I Skip?',
                          subtitle:
                              'See how skipping this topic can affect future learning.',
                          iconBackground: secondarySurface,
                          iconColor:
                              AppTheme.warningOrange,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'What If I Skip?',
                              isDark,
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // =================================================
                  // STUDY RESOURCES
                  // =================================================

                  _buildSectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: 'Study Resources',
                    subtitle:
                        'Use additional resources to strengthen your understanding.',
                    count: '3 Resources',
                    mainText: mainText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 14),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildExploreCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            mainText: mainText,
                            secondaryText: secondaryText,
                            icon: Icons.description_rounded,
                            title: 'Generated Notes',
                            subtitle:
                                'Read topic-specific notes prepared for learning.',
                            iconBackground:
                                secondarySurface,
                            iconColor:
                                AppTheme.successGreen,
                            onTap: () {
                              _showComingSoon(
                                context,
                                'Generated Notes',
                                isDark,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildExploreCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            mainText: mainText,
                            secondaryText: secondaryText,
                            icon: Icons.psychology_rounded,
                            title: 'Quiz',
                            subtitle:
                                'Test your understanding with topic-based questions.',
                            iconBackground:
                                secondarySurface,
                            iconColor:
                                AppTheme.gradientPurpleEnd,
                            onTap: () {
                              _showComingSoon(
                                context,
                                'Quiz',
                                isDark,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon: Icons.description_rounded,
                          title: 'Generated Notes',
                          subtitle:
                              'Read topic-specific notes prepared for learning.',
                          iconBackground: secondarySurface,
                          iconColor:
                              AppTheme.successGreen,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'Generated Notes',
                              isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildExploreCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainText: mainText,
                          secondaryText: secondaryText,
                          icon: Icons.psychology_rounded,
                          title: 'Quiz',
                          subtitle:
                              'Test your understanding with topic-based questions.',
                          iconBackground: secondarySurface,
                          iconColor:
                              AppTheme.gradientPurpleEnd,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'Quiz',
                              isDark,
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 14),

                  _buildExploreCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    mainText: mainText,
                    secondaryText: secondaryText,
                    icon: Icons.play_circle_fill_rounded,
                    title: 'YouTube Recommended Videos',
                    subtitle:
                        'Watch recommended videos to explore the topic further.',
                    iconBackground: secondarySurface,
                    iconColor: AppTheme.warningOrange,
                    onTap: () {
                      _showComingSoon(
                        context,
                        'YouTube Recommended Videos',
                        isDark,
                      );
                    },
                  ),

                  const SizedBox(height: 34),

                  // =================================================
                  // PREREQUISITES
                  // =================================================

                  Text(
                    'Prerequisites',
                    style: TextStyle(
                      color: mainText,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (prerequisites.isEmpty)
                    _emptyCard(
                      'This topic has no prerequisites.',
                      cardColor,
                      borderColor,
                      secondaryText,
                    )
                  else
                    ...prerequisites.map(
                      (topic) => _topicCard(
                        context: context,
                        topic: topic,
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppTheme.successGreen,
                        backgroundColor: secondarySurface,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        mainText: mainText,
                        secondaryText: secondaryText,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // =================================================
                  // POST REQUISITES
                  // =================================================

                  Text(
                    'Post requisites',
                    style: TextStyle(
                      color: mainText,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'This topic is useful in these further topics:',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (usedInTopics.isEmpty)
                    _emptyCard(
                      'This topic is not directly used in another topic yet.',
                      cardColor,
                      borderColor,
                      secondaryText,
                    )
                  else
                    ...usedInTopics.map(
                      (topic) => _topicCard(
                        context: context,
                        topic: topic,
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppTheme.warningOrange,
                        backgroundColor: secondarySurface,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        mainText: mainText,
                        secondaryText: secondaryText,
                      ),
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // CURRENT TOPIC HEADER
  // =============================================================

  Widget _buildTopicHeader({
    required bool isDark,
    required Color secondarySurface,
    required Color mainText,
    required Color secondaryText,
  }) {
    final dividerColor = isDark
        ? const Color(0xFF293253)
        : const Color(0xFFE8E6F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: secondarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(
            alpha: 0.65,
          ),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT TOPIC',
                  style: TextStyle(
                    color: AppTheme.gradientPurpleEnd,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.7,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  selectedTopic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mainText,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Subject: ',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                      TextSpan(
                        text: subject,
                        style: const TextStyle(
                          color: AppTheme.gradientPurpleEnd,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 13),

                Container(
                  width: 240,
                  height: 1,
                  color: dividerColor,
                ),

                const SizedBox(height: 11),

                Text(
                  'Choose how you want to learn this topic.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          const Column(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: AppTheme.warningOrange,
                size: 31,
              ),
              SizedBox(height: 4),
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryPurple,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION HEADER
  // =============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required String count,
    required Color mainText,
    required Color secondaryText,
    required bool isDark,
  }) {
    final surfaceColor = isDark
        ? AppTheme.darkSecondary
        : AppTheme.lightSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(
                alpha: 0.45,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.gradientPurpleEnd,
            size: 19,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(
                alpha: 0.45,
              ),
            ),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: AppTheme.gradientPurpleEnd,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // EXPLORE CARD
  // =============================================================

  Widget _buildExploreCard({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color mainText,
    required Color secondaryText,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 124,
          ),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mainText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.05,
                          height: 1.22,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: secondaryText,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TOPIC CARD
  // =============================================================

  static Widget _topicCard({
    required BuildContext context,
    required Topic topic,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color cardColor,
    required Color borderColor,
    required Color mainText,
    required Color secondaryText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    _GraphNavigationScreen(
                  selectedTopic: topic,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    topic.name,
                    style: TextStyle(
                      color: mainText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: secondaryText,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // EMPTY CARD
  // =============================================================

  static Widget _emptyCard(
    String message,
    Color cardColor,
    Color borderColor,
    Color secondaryText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  // =============================================================
  // COMING SOON
  // =============================================================

  static void _showComingSoon(
    BuildContext context,
    String feature,
    bool isDark,
  ) {
    final backgroundColor = isDark
        ? AppTheme.darkSecondary
        : AppTheme.lightSecondary;

    final textColor = isDark
        ? AppTheme.darkMainText
        : AppTheme.lightMainText;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            '$feature will open here.',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =============================================================
// GRAPH NAVIGATION
// =============================================================

class _GraphNavigationScreen extends StatelessWidget {
  final Topic selectedTopic;

  const _GraphNavigationScreen({
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    return _GraphScreenWrapper(
      selectedTopic: selectedTopic,
    );
  }
}

// =============================================================
// GRAPH WRAPPER
// =============================================================

class _GraphScreenWrapper extends StatelessWidget {
  final Topic selectedTopic;

  const _GraphScreenWrapper({
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: PrerequisiteGraphScreen(
        selectedTopic: selectedTopic,
        subject: selectedTopic.subject,
      ),
    );
  }
}