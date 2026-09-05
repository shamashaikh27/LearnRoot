
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';
import 'topic_details_screen.dart';

// =============================================================
// MAIN TOPIC SEARCH SCREEN
// =============================================================

class GraphScreen extends StatefulWidget {
  final String subject;
  final List<Topic> topics;

  const GraphScreen({
    super.key,
    required this.subject,
    required this.topics,
  });

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show topics belonging to the selected subject
    final filteredTopics = widget.topics.where((topic) {
      return topic.name
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      // =======================================================
      // TOPIC LIST APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,

        title: Text(
          widget.subject,
          style: const TextStyle(
            color: Color(0xFF252238),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // =====================================================
          // SEARCH BAR
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),
            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: 'Search topic...',

                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6C63A8),
                ),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.grey,
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
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF6C63A8),
                    width: 1.5,
                  ),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // =====================================================
          // TOPIC LIST
          // =====================================================

          Expanded(
            child: filteredTopics.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 55,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No matching topic found.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252238),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Try searching for another topic.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),

                    itemCount: filteredTopics.length,

                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),

                          leading: Container(
                            width: 44,
                            height: 44,

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFEDEBFA),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            child: const Icon(
                              Icons.account_tree_rounded,
                              color:
                                  Color(0xFF6C63A8),
                            ),
                          ),

                          title: Text(
                            topic.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Color(0xFF252238),
                            ),
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                            color: Colors.grey,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PrerequisiteGraphScreen(
                                  selectedTopic: topic,
                                  subject: widget.subject,
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

// =============================================================
// PREREQUISITE GRAPH SCREEN
// =============================================================

class PrerequisiteGraphScreen extends StatelessWidget {
  final Topic selectedTopic;
  final String subject;

  const PrerequisiteGraphScreen({
    super.key,
    required this.selectedTopic,
    required this.subject,
  });

  // ===========================================================
  // FIND DIRECT PREREQUISITES
  // ===========================================================

  List<Topic> get prerequisiteTopics {
    final result = <Topic>[];

    final subjectTopics = syllabusTopics.where((topic) {
      return topic.subject == subject;
    }).toList();

    for (final id in selectedTopic.prerequisites) {
      for (final topic in subjectTopics) {
        if (topic.id == id) {
          result.add(topic);
          break;
        }
      }
    }

    return result;
  }

  // ===========================================================
  // FIND DIRECT USED-IN TOPICS
  // ===========================================================

  List<Topic> get usedInTopics {
    return syllabusTopics.where((topic) {
      return topic.subject == subject &&
          topic.prerequisites.contains(selectedTopic.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prerequisites = prerequisiteTopics;
    final usedIn = usedInTopics;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      // =======================================================
      // GRAPH SCREEN APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,

        // LEFT SIDE → PREVIOUS GRAPH
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF252238),
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          selectedTopic.name,
          style: const TextStyle(
            color: Color(0xFF252238),
            fontWeight: FontWeight.bold,
          ),
        ),

        // RIGHT SIDE → TOPIC LIST
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF252238),
            ),

            onPressed: () {
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == '/topicList',
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // GRAPH AREA
            // =================================================

            Expanded(
              child: _GraphArea(
                selectedTopic: selectedTopic,
                prerequisiteTopics: prerequisites,
                usedInTopics: usedIn,
              ),
            ),

            // =================================================
            // EXPLORE SELECTED TOPIC
            // =================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                8,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6C63A8),
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TopicDetailsScreen(
                          selectedTopic: selectedTopic,
                          subject: selectedTopic.subject,
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                  ),

                  label: Text(
                    'Explore ${selectedTopic.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),

            // =================================================
            // HOW TO READ
            // =================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                12,
              ),

              child: SizedBox(
                width: double.infinity,

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Text(
                      'How to read: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),

                    _LegendItem(
                      color:
                          const Color(0xFF66A66B),
                      text:
                          'Prerequisite — required concept',
                    ),

                    const SizedBox(width: 16),

                    _LegendItem(
                      color:
                          const Color(0xFF6C63A8),
                      text:
                          'Current Topic — selected topic',
                    ),

                    const SizedBox(width: 16),

                    _LegendItem(
                      color:
                          const Color(0xFFE6A34A),
                      text:
                          'Post requisite — where this topic is further used',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// GRAPH AREA
// =============================================================

class _GraphArea extends StatelessWidget {
  final Topic selectedTopic;
  final List<Topic> prerequisiteTopics;
  final List<Topic> usedInTopics;

  const _GraphArea({
    required this.selectedTopic,
    required this.prerequisiteTopics,
    required this.usedInTopics,
  });

  @override
  Widget build(BuildContext context) {
    if (prerequisiteTopics.isEmpty &&
        usedInTopics.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.account_tree_rounded,
                size: 55,
                color: Color(0xFF6C63A8),
              ),

              const SizedBox(height: 14),

              Text(
                selectedTopic.name,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252238),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'No directly connected topics.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 0.7,
          maxScale: 2.5,

          boundaryMargin:
              const EdgeInsets.all(100),

          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,

            child: CustomPaint(
              painter:
                  _PrerequisiteGraphPainter(
                prerequisiteCount:
                    prerequisiteTopics.length,
                usedInCount:
                    usedInTopics.length,
              ),

              child: Stack(
                children: [
                  // PREREQUISITES

                  ..._buildPrerequisiteNodes(
                    context,
                    constraints,
                  ),

                  // CURRENT TOPIC

                  _positionedNode(
                    context: context,
                    topic: selectedTopic,
                    type: _NodeType.current,

                    left:
                        constraints.maxWidth * 0.5 -
                            105,

                    top:
                        constraints.maxHeight * 0.5 -
                            30,

                    width: 210,
                  ),

                  // USED-IN TOPICS

                  ..._buildUsedInNodes(
                    context,
                    constraints,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // PREREQUISITE NODE POSITIONS
  // ===========================================================

  List<Widget> _buildPrerequisiteNodes(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final widgets = <Widget>[];

    if (prerequisiteTopics.isEmpty) {
      return widgets;
    }

    final double availableWidth =
        constraints.maxWidth;

    final double spacing =
        availableWidth /
            (prerequisiteTopics.length + 1);

    for (int i = 0;
        i < prerequisiteTopics.length;
        i++) {
      widgets.add(
        _positionedNode(
          context: context,
          topic: prerequisiteTopics[i],
          type: _NodeType.prerequisite,

          left:
              spacing * (i + 1) - 95,

          top: 30,

          width: 190,
        ),
      );
    }

    return widgets;
  }

  // ===========================================================
  // USED-IN NODE POSITIONS
  // ===========================================================

  List<Widget> _buildUsedInNodes(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final widgets = <Widget>[];

    if (usedInTopics.isEmpty) {
      return widgets;
    }

    final double availableWidth =
        constraints.maxWidth;

    final double spacing =
        availableWidth /
            (usedInTopics.length + 1);

    for (int i = 0;
        i < usedInTopics.length;
        i++) {
      widgets.add(
        _positionedNode(
          context: context,
          topic: usedInTopics[i],
          type: _NodeType.usedIn,

          left:
              spacing * (i + 1) - 95,

          top:
              constraints.maxHeight - 100,

          width: 190,
        ),
      );
    }

    return widgets;
  }

  // ===========================================================
  // POSITIONED NODE
  // ===========================================================

  Widget _positionedNode({
    required BuildContext context,
    required Topic topic,
    required _NodeType type,
    required double left,
    required double top,
    required double width,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    final bool isCurrent =
        type == _NodeType.current;

    if (type == _NodeType.prerequisite) {
      backgroundColor =
          const Color(0xFFE8F5E9);

      borderColor =
          const Color(0xFF66A66B);

      textColor =
          const Color(0xFF356B3B);
    } else if (type == _NodeType.usedIn) {
      backgroundColor =
          const Color(0xFFFFF2E1);

      borderColor =
          const Color(0xFFE6A34A);

      textColor =
          const Color(0xFF8A5A16);
    } else {
      backgroundColor =
          const Color(0xFF6C63A8);

      borderColor =
          const Color(0xFF6C63A8);

      textColor =
          Colors.white;
    }

    return Positioned(
      left: left,
      top: top,

      child: GestureDetector(
        onTap: () {
          if (topic.id ==
              selectedTopic.id) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PrerequisiteGraphScreen(
                selectedTopic: topic,
                subject: topic.subject,
              ),
            ),
          );
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),

          width: width,

          constraints:
              const BoxConstraints(
            minHeight: 60,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: backgroundColor,

            border: Border.all(
              color: borderColor,
              width: isCurrent ? 3 : 2,
            ),

            borderRadius:
                BorderRadius.circular(
              isCurrent ? 18 : 14,
            ),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),

          child: Text(
            topic.name,
            textAlign: TextAlign.center,

            style: TextStyle(
              color: textColor,
              fontSize:
                  isCurrent ? 16 : 13,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// NODE TYPE
// =============================================================

enum _NodeType {
  prerequisite,
  current,
  usedIn,
}

// =============================================================
// CUSTOM GRAPH PAINTER
// =============================================================

class _PrerequisiteGraphPainter
    extends CustomPainter {
  final int prerequisiteCount;
  final int usedInCount;

  _PrerequisiteGraphPainter({
    required this.prerequisiteCount,
    required this.usedInCount,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint linePaint = Paint()
      ..color =
          const Color(0xFFB5B0D4)
      ..strokeWidth = 2.2
      ..style =
          PaintingStyle.stroke;

    final double centerX =
        size.width * 0.5;

    final double centerY =
        size.height * 0.5;

    // =========================================================
    // PREREQUISITE → CURRENT
    // =========================================================

    if (prerequisiteCount > 0) {
      final double spacing =
          size.width /
              (prerequisiteCount + 1);

      for (int i = 0;
          i < prerequisiteCount;
          i++) {
        final double startX =
            spacing * (i + 1);

        final double startY = 90;

        final double endX =
            centerX;

        final double endY =
            centerY - 30;

        _drawCurvedArrow(
          canvas,
          startX,
          startY,
          endX,
          endY,
          linePaint,
        );
      }
    }

    // =========================================================
    // CURRENT → USED-IN
    // =========================================================

    if (usedInCount > 0) {
      final double spacing =
          size.width /
              (usedInCount + 1);

      for (int i = 0;
          i < usedInCount;
          i++) {
        final double startX =
            centerX;

        final double startY =
            centerY + 30;

        final double endX =
            spacing * (i + 1);

        final double endY =
            size.height - 100;

        _drawCurvedArrow(
          canvas,
          startX,
          startY,
          endX,
          endY,
          linePaint,
        );
      }
    }
  }

  // ===========================================================
  // CURVED ARROW
  // ===========================================================

  void _drawCurvedArrow(
    Canvas canvas,
    double startX,
    double startY,
    double endX,
    double endY,
    Paint paint,
  ) {
    final Path path = Path();

    path.moveTo(
      startX,
      startY,
    );

    final double middleY =
        (startY + endY) / 2;

    path.cubicTo(
      startX,
      middleY,
      endX,
      middleY,
      endX,
      endY,
    );

    canvas.drawPath(
      path,
      paint,
    );

    // =========================================================
    // ARROW HEAD
    // =========================================================

    final double angle =
        math.atan2(
      endY - startY,
      endX - startX,
    );

    const double arrowLength = 10;
    const double arrowAngle = 0.55;

    final Paint arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2.2
      ..style =
          PaintingStyle.stroke;

    final Path arrowPath = Path();

    arrowPath.moveTo(
      endX,
      endY,
    );

    arrowPath.lineTo(
      endX -
          arrowLength *
              math.cos(
                angle - arrowAngle,
              ),
      endY -
          arrowLength *
              math.sin(
                angle - arrowAngle,
              ),
    );

    arrowPath.moveTo(
      endX,
      endY,
    );

    arrowPath.lineTo(
      endX -
          arrowLength *
              math.cos(
                angle + arrowAngle,
              ),
      endY -
          arrowLength *
              math.sin(
                angle + arrowAngle,
              ),
    );

    canvas.drawPath(
      arrowPath,
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PrerequisiteGraphPainter
        oldDelegate,
  ) {
    return oldDelegate.prerequisiteCount !=
            prerequisiteCount ||
        oldDelegate.usedInCount !=
            usedInCount;
  }
}

// =============================================================
// HOW TO READ LEGEND
// =============================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Container(
          width: 13,
          height: 13,

          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color:
                Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
