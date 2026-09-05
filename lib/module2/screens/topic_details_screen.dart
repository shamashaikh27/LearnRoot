import 'package:flutter/material.dart';

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

  // =============================================================
  // LEARNROOT THEME
  // =============================================================

  static const Color primaryPurple = Color(0xFF593AB9);
  static const Color darkNavy = Color(0xFF030C1D);
  static const Color secondaryNavy = Color(0xFF0E1532);
  static const Color cardNavy = Color(0xFF151D3B);

  static const Color lightText = Color(0xFFE8E5ED);
  static const Color secondaryText = Color(0xFFAAB1C8);

  static const Color successGreen = Color(0xFF35D07F);
  static const Color warningOrange = Color(0xFFF4A62A);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // FIND PREREQUISITES
    // ==========================================================

    final prerequisites = syllabusTopics
        .where(
          (topic) =>
              selectedTopic.prerequisites.contains(topic.id),
        )
        .toList();

    // ==========================================================
    // FIND TOPICS THAT USE THIS TOPIC
    // ==========================================================

    final usedInTopics = syllabusTopics
        .where(
          (topic) =>
              topic.prerequisites.contains(selectedTopic.id),
        )
        .toList();

    return Scaffold(
      backgroundColor: darkNavy,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: darkNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: lightText,
            size: 23,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: const Text(
          'Explore Topic',
          style: TextStyle(
            color: lightText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.1,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Bookmark',
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: lightText,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bookmark feature coming later.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

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
                  // ==================================================
                  // CURRENT TOPIC HEADER
                  // ==================================================

                  _buildTopicHeader(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // AI LEARNING SECTION
                  // ==================================================

                  _buildSectionHeader(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Learning',
                    subtitle:
                        'Learn this topic with intelligent AI-powered tools.',
                    count: '4 Tools',
                  ),

                  const SizedBox(height: 12),

                  if (isWide)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildExploreCard(
                                icon: Icons.auto_awesome_rounded,
                                title: 'AI Summary',
                                subtitle:
                                    'Get a simple and concise summary of this topic.',
                                iconBackground:
                                    const Color(0xFF593AB9),
                                iconColor: Colors.white,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Summary',
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              _buildExploreCard(
                                icon: Icons.chat_bubble_rounded,
                                title: 'AI Doubt Solver',
                                subtitle:
                                    'Ask questions and clear your doubts with AI.',
                                iconBackground:
                                    const Color(0xFF104B63),
                                iconColor:
                                    const Color(0xFF38C5F4),
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Doubt Solver',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            children: [
                              _buildExploreCard(
                                icon: Icons.auto_graph_rounded,
                                title: 'AI Visual Explanation',
                                subtitle:
                                    'Understand concepts through visual explanations.',
                                iconBackground:
                                    const Color(0xFF4A214F),
                                iconColor:
                                    const Color(0xFFE56BD0),
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'AI Visual Explanation',
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              _buildExploreCard(
                                icon:
                                    Icons.warning_amber_rounded,
                                title: 'What If I Skip?',
                                subtitle:
                                    'See how skipping this topic can affect future learning.',
                                iconBackground:
                                    const Color(0xFF5A3A08),
                                iconColor: warningOrange,
                                onTap: () {
                                  _showComingSoon(
                                    context,
                                    'What If I Skip?',
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
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI Summary',
                          subtitle:
                              'Get a simple and concise summary of this topic.',
                          iconBackground:
                              const Color(0xFF593AB9),
                          iconColor: Colors.white,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Summary',
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildExploreCard(
                          icon: Icons.auto_graph_rounded,
                          title: 'AI Visual Explanation',
                          subtitle:
                              'Understand concepts through visual explanations.',
                          iconBackground:
                              const Color(0xFF4A214F),
                          iconColor:
                              const Color(0xFFE56BD0),
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Visual Explanation',
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildExploreCard(
                          icon: Icons.chat_bubble_rounded,
                          title: 'AI Doubt Solver',
                          subtitle:
                              'Ask questions and clear your doubts with AI.',
                          iconBackground:
                              const Color(0xFF104B63),
                          iconColor:
                              const Color(0xFF38C5F4),
                          onTap: () {
                            _showComingSoon(
                              context,
                              'AI Doubt Solver',
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildExploreCard(
                          icon:
                              Icons.warning_amber_rounded,
                          title: 'What If I Skip?',
                          subtitle:
                              'See how skipping this topic can affect future learning.',
                          iconBackground:
                              const Color(0xFF5A3A08),
                          iconColor: warningOrange,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'What If I Skip?',
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // STUDY RESOURCES SECTION
                  // ==================================================

                  _buildSectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: 'Study Resources',
                    subtitle:
                        'Use additional resources to strengthen your understanding.',
                    count: '3 Resources',
                  ),

                  const SizedBox(height: 12),

                  if (isWide)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildExploreCard(
                            icon: Icons.description_rounded,
                            title: 'Generated Notes',
                            subtitle:
                                'Read topic-specific notes prepared for learning.',
                            iconBackground:
                                const Color(0xFF07533E),
                            iconColor: successGreen,
                            onTap: () {
                              _showComingSoon(
                                context,
                                'Generated Notes',
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildExploreCard(
                            icon: Icons.psychology_rounded,
                            title: 'Quiz',
                            subtitle:
                                'Test your understanding with topic-based questions.',
                            iconBackground:
                                const Color(0xFF352477),
                            iconColor:
                                const Color(0xFFB39DFF),
                            onTap: () {
                              _showComingSoon(
                                context,
                                'Quiz',
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
                          icon: Icons.description_rounded,
                          title: 'Generated Notes',
                          subtitle:
                              'Read topic-specific notes prepared for learning.',
                          iconBackground:
                              const Color(0xFF07533E),
                          iconColor: successGreen,
                          onTap: () {
                            _showComingSoon(
                              context,
                              'Generated Notes',
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildExploreCard(
                          icon: Icons.psychology_rounded,
                          title: 'Quiz',
                          subtitle:
                              'Test your understanding with topic-based questions.',
                          iconBackground:
                              const Color(0xFF352477),
                          iconColor:
                              const Color(0xFFB39DFF),
                          onTap: () {
                            _showComingSoon(
                              context,
                              'Quiz',
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // YOUTUBE
                  // ==================================================

                  _buildExploreCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: 'YouTube Recommended Videos',
                    subtitle:
                        'Watch recommended videos to explore the topic further.',
                    iconBackground:
                        const Color(0xFF642438),
                    iconColor:
                        const Color(0xFFFF4D61),
                    onTap: () {
                      _showComingSoon(
                        context,
                        'YouTube Recommended Videos',
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // PREREQUISITES
                  // ==================================================

                  const Text(
                    'Prerequisites',
                    style: TextStyle(
                      color: lightText,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (prerequisites.isEmpty)
                    _emptyCard(
                      'This topic has no prerequisites.',
                    )
                  else
                    ...prerequisites.map(
                      (topic) => _topicCard(
                        context: context,
                        topic: topic,
                        icon: Icons.arrow_upward_rounded,
                        iconColor: successGreen,
                        backgroundColor:
                            const Color(0xFF07533E),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // POST REQUISITES
                  // ==================================================

                  const Text(
                    'Post requisites',
                    style: TextStyle(
                      color: lightText,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'This topic is useful in these further topics:',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (usedInTopics.isEmpty)
                    _emptyCard(
                      'This topic is not directly used in another topic yet.',
                    )
                  else
                    ...usedInTopics.map(
                      (topic) => _topicCard(
                        context: context,
                        topic: topic,
                        icon: Icons.arrow_downward_rounded,
                        iconColor: warningOrange,
                        backgroundColor:
                            const Color(0xFF5A3A08),
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

  Widget _buildTopicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: secondaryNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryPurple.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------
          // TOPIC ICON
          // -------------------------------------------------------

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          // -------------------------------------------------------
          // TOPIC INFORMATION
          // -------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT TOPIC',
                  style: TextStyle(
                    color: Color(0xFFB39DFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  selectedTopic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.35,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 5),

                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Subject: ',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      TextSpan(
                        text: subject,
                        style: const TextStyle(
                          color: Color(0xFFB39DFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 240,
                  height: 1,
                  color: const Color(0xFF293253),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Choose how you want to learn this topic.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // -------------------------------------------------------
          // DECORATIVE LEARNING ICON
          // -------------------------------------------------------

          const Column(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: warningOrange,
                size: 31,
              ),
              SizedBox(height: 4),
              Icon(
                Icons.auto_awesome,
                color: primaryPurple,
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
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF17103B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primaryPurple.withValues(alpha: 0.45),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB39DFF),
            size: 19,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  letterSpacing: 0.05,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF100B2B),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: primaryPurple.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: Color(0xFFB39DFF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
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
            minHeight: 118,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardNavy,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFF222D50),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------
              // ICON
              // ---------------------------------------------------

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

              const SizedBox(width: 12),

              // ---------------------------------------------------
              // TEXT
              // ---------------------------------------------------

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ---------------------------------------------------
              // ARROW
              // ---------------------------------------------------

              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9DA7C3),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF222D50),
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
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                        BorderRadius.circular(10),
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
                    style: const TextStyle(
                      color: lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.05,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9DA7C3),
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

  static Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF222D50),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  // =============================================================
  // COMING SOON / PLACEHOLDER
  // =============================================================

  static void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: secondaryNavy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            '$feature will open here.',
            style: const TextStyle(
              color: lightText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// =============================================================
// SMALL NAVIGATION SCREEN
// =============================================================
//
// Preserves the existing prerequisite / Used In behavior.
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
      backgroundColor: const Color(0xFF030C1D),
      body: PrerequisiteGraphScreen(
        selectedTopic: selectedTopic,
        subject: selectedTopic.subject,
      ),
    );
  }
}