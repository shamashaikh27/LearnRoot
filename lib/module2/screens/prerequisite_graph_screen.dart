import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';
import 'topic_details_screen.dart';

class PrerequisiteGraphScreen extends StatelessWidget {
  final Topic selectedTopic;

  const PrerequisiteGraphScreen({
    super.key,
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // FIND DIRECT PREREQUISITES
    // ==========================================================

    final List<Topic> prerequisiteTopics = [];

    for (final prerequisiteId in selectedTopic.prerequisites) {
      final matches = syllabusTopics.where(
        (topic) => topic.id == prerequisiteId,
      );

      if (matches.isNotEmpty) {
        prerequisiteTopics.add(matches.first);
      }
    }

    // ==========================================================
    // FIND TOPICS WHERE THIS TOPIC IS USED
    // ==========================================================

    final List<Topic> usedInTopics = syllabusTopics.where((topic) {
      return topic.prerequisites.contains(selectedTopic.id);
    }).toList();

    // ==========================================================
    // CREATE GRAPH
    // ==========================================================

    final graph = Graph();

    final selectedNode = Node.Id(selectedTopic.id);

    graph.addNode(selectedNode);

    // ==========================================================
    // ADD PREREQUISITES
    // ==========================================================

    for (final prerequisiteTopic in prerequisiteTopics) {
      final prerequisiteNode = Node.Id(prerequisiteTopic.id);

      graph.addNode(prerequisiteNode);

      // Prerequisite → Current Topic
      graph.addEdge(
        prerequisiteNode,
        selectedNode,
      );
    }

    // ==========================================================
    // ADD USED-IN TOPICS
    // ==========================================================

    for (final usedInTopic in usedInTopics) {
      final usedInNode = Node.Id(usedInTopic.id);

      graph.addNode(usedInNode);

      // Current Topic → Further Topic
      graph.addEdge(
        selectedNode,
        usedInNode,
      );
    }

    // ==========================================================
    // SCREEN
    // ==========================================================

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
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

      body: Column(
        children: [
          // =====================================================
          // LEARNING MAP HEADER
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: Column(
              children: [
                const Text(
                  'Learning Map',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252238),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'See what you need to know and where this topic is used.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // GRAPH
          // =====================================================

          Expanded(
            child: (prerequisiteTopics.isEmpty &&
                    usedInTopics.isEmpty)
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_tree_rounded,
                            size: 55,
                            color: Color(0xFF6C63A8),
                          ),

                          SizedBox(height: 15),

                          Text(
                            'This is a starting topic.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF252238),
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'There are no directly connected topics.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(150),
                    minScale: 0.4,
                    maxScale: 4.0,

                    child: Center(
                      child: GraphView(
                        graph: graph,

                        algorithm: SugiyamaAlgorithm(
                          SugiyamaConfiguration(),
                        ),

                        paint: Paint()
                          ..color =
                              const Color(0xFFB5B0D4)
                          ..strokeWidth = 2
                          ..style =
                              PaintingStyle.stroke,

                        builder: (Node node) {
                          final topicId =
                              node.key?.value as String;

                          final topic =
                              syllabusTopics.firstWhere(
                            (topic) =>
                                topic.id == topicId,
                          );

                          // ====================================
                          // NODE TYPE
                          // ====================================

                          final bool isSelectedTopic =
                              topic.id ==
                                  selectedTopic.id;

                          final bool isPrerequisite =
                              selectedTopic.prerequisites
                                  .contains(topic.id);

                          final bool isUsedIn =
                              topic.prerequisites.contains(
                            selectedTopic.id,
                          );

                          // ====================================
                          // NODE COLORS
                          // ====================================

                          Color backgroundColor;
                          Color borderColor;
                          Color textColor;

                          if (isSelectedTopic) {
                            // CURRENT TOPIC

                            backgroundColor =
                                const Color(0xFF6C63A8);

                            borderColor =
                                const Color(0xFF6C63A8);

                            textColor =
                                Colors.white;
                          } else if (isPrerequisite) {
                            // PREREQUISITE

                            backgroundColor =
                                const Color(0xFFE8F5E9);

                            borderColor =
                                const Color(0xFF66A66B);

                            textColor =
                                const Color(0xFF356B3B);
                          } else if (isUsedIn) {
                            // USED IN

                            backgroundColor =
                                const Color(0xFFFFF2E1);

                            borderColor =
                                const Color(0xFFE6A34A);

                            textColor =
                                const Color(0xFF8A5A16);
                          } else {
                            backgroundColor =
                                Colors.white;

                            borderColor =
                                Colors.grey;

                            textColor =
                                Colors.black87;
                          }

                          // ====================================
                          // NODE
                          // ====================================

                          return GestureDetector(
                            onTap: () {
                              if (topic.id ==
                                  selectedTopic.id) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PrerequisiteGraphScreen(
                                    selectedTopic:
                                        topic,
                                  ),
                                ),
                              );
                            },

                            child: Container(
                              constraints:
                                  const BoxConstraints(
                                minWidth: 145,
                                maxWidth: 220,
                              ),

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    backgroundColor,

                                border:
                                    Border.all(
                                  color:
                                      borderColor,
                                  width: 2,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),

                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 7,
                                    offset:
                                        Offset(0, 3),
                                    color:
                                        Colors.black12,
                                  ),
                                ],
                              ),

                              child: Text(
                                topic.name,
                                textAlign:
                                    TextAlign.center,

                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),

          // =====================================================
          // BOTTOM INFORMATION
          // =====================================================

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            padding: const EdgeInsets.fromLTRB(
              4,
              4,
              4,
              0,
            ),

            child: Column(
              children: [
                // -------------------------------------------------
                // PREREQUISITES
                // -------------------------------------------------

                if (prerequisiteTopics.isNotEmpty)
                  _infoRow(
                    icon:
                        Icons.arrow_upward_rounded,

                    title: 'Prerequisites',

                    text:
                        '${prerequisiteTopics.length} prerequisite topic${prerequisiteTopics.length == 1 ? '' : 's'}',

                    color:
                        const Color(0xFF4D8754),
                  ),

                // -------------------------------------------------
                // USED IN
                // -------------------------------------------------

                if (usedInTopics.isNotEmpty)
                  _infoRow(
                    icon:
                        Icons.arrow_downward_rounded,

                    title: 'Used In',

                    text:
                        '${usedInTopics.length} further topic${usedInTopics.length == 1 ? '' : 's'}',

                    color:
                        const Color(0xFFB47725),
                  ),

                // -------------------------------------------------
                // NO CONNECTIONS
                // -------------------------------------------------

                if (prerequisiteTopics.isEmpty &&
                    usedInTopics.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(bottom: 8),

                    child: Text(
                      'No directly connected topics.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // =====================================================
          // TOPIC DETAILS BUTTON
          // =====================================================

          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6C63A8),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TopicDetailsScreen(
                        selectedTopic:
                            selectedTopic,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.menu_book_rounded,
                ),

                label: Text(
                  'Explore ${selectedTopic.name}',
                  style: const TextStyle(
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

  // =============================================================
  // INFORMATION ROW
  // =============================================================

  static Widget _infoRow({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),

      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),

          const SizedBox(width: 8),

          Text(
            '$title: ',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}