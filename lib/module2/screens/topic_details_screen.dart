import 'graph_screen.dart';
import 'package:flutter/material.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';

class TopicDetailsScreen extends StatelessWidget {
  final Topic selectedTopic;

  const TopicDetailsScreen({
    super.key,
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // FIND PREREQUISITES
    // ==========================================================

    final prerequisites = syllabusTopics.where(
      (topic) => selectedTopic.prerequisites
          .contains(topic.id),
    ).toList();

    // ==========================================================
    // FIND TOPICS THAT USE THIS TOPIC
    // ==========================================================

    final usedInTopics = syllabusTopics.where(
      (topic) => topic.prerequisites
          .contains(selectedTopic.id),
    ).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F7FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF8F7FC),

        elevation: 0,

        title: Text(
          selectedTopic.name,

          style: const TextStyle(
            color: Color(0xFF252238),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // TOPIC TITLE
            // ==================================================

            Center(
              child: Text(
                selectedTopic.name,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252238),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // AI EXPLANATION
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(18),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(0xFFEDEBFA),

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: const Icon(
                          Icons.auto_awesome,
                          color:
                              Color(0xFF6C63A8),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'AI Explanation',

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF252238),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'AI-generated summarized explanation '
                    'with examples and visual explanations '
                    'will appear here.',

                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF555555),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    height: 48,

                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF6C63A8,
                        ),

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'AI explanation will be connected later.',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.play_circle_outline,
                      ),

                      label: const Text(
                        'Start AI Explanation',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // PREREQUISITES
            // ==================================================

            const Text(
              'Prerequisites',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252238),
              ),
            ),

            const SizedBox(height: 10),

            if (prerequisites.isEmpty)
              _emptyCard(
                'This topic has no prerequisites.',
              )
            else
              ...prerequisites.map(
                (topic) => _topicCard(
                  context: context,
                  topic: topic,
                  icon:
                      Icons.arrow_upward_rounded,
                  iconColor:
                      const Color(0xFF4D8754),
                  backgroundColor:
                      const Color(0xFFE8F5E9),
                ),
              ),

            const SizedBox(height: 28),

            // ==================================================
            // USED IN
            // ==================================================

            const Text(
              'Post requisites',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252238),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'This topic is useful in these further topics:',

              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 10),

            if (usedInTopics.isEmpty)
              _emptyCard(
                'This topic is not directly used in another topic yet.',
              )
            else
              ...usedInTopics.map(
                (topic) => _topicCard(
                  context: context,
                  topic: topic,
                  icon:
                      Icons.arrow_downward_rounded,
                  iconColor:
                      const Color(0xFFB47725),
                  backgroundColor:
                      const Color(0xFFFFF2E1),
                ),
              ),

            const SizedBox(height: 28),

            // ==================================================
            // EXPLORE FURTHER
            // ==================================================

            const Text(
              'Explore Further',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252238),
              ),
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // NOTES
            // --------------------------------------------------

            _exploreCard(
              context: context,

              icon: Icons.description_outlined,

              title: 'Notes',

              subtitle:
                  'Read detailed notes about this topic',
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // YOUTUBE
            // --------------------------------------------------

            _exploreCard(
              context: context,

              icon: Icons.play_circle_outline,

              title:
                  'YouTube Recommendations',

              subtitle:
                  'Watch recommended videos about this topic',
            ),

            const SizedBox(height: 30),
          ],
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
      margin:
          const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: backgroundColor,

            borderRadius:
                BorderRadius.circular(11),
          ),

          child: Icon(
            icon,
            color: iconColor,
            size: 21,
          ),
        ),

        title: Text(
          topic.name,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF252238),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),

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
      ),
    );
  }

  // =============================================================
  // EMPTY CARD
  // =============================================================

  static Widget _emptyCard(
    String message,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Text(
        message,

        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  // =============================================================
  // EXPLORE CARD
  // =============================================================

  static Widget _exploreCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        leading: Container(
          width: 44,
          height: 44,

          decoration: BoxDecoration(
            color: const Color(0xFFEDEBFA),

            borderRadius:
                BorderRadius.circular(11),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF6C63A8),
          ),
        ),

        title: Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF252238),
          ),
        ),

        subtitle: Text(
          subtitle,

          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),

        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                '$title will be connected later.',
              ),
            ),
          );
        },
      ),
    );
  }
}


// =============================================================
// SMALL NAVIGATION SCREEN
// =============================================================
//
// This lets the prerequisite / Used In cards open
// the selected topic's graph without creating
// circular imports between screens.
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
      body: PrerequisiteGraphScreen(
        selectedTopic: selectedTopic,
      ),
    );
  }
}
