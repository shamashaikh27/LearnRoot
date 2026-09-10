import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';
import '../../theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    final cardColor = isDark
        ? AppTheme.darkCard
        : AppTheme.lightCard;

    final secondarySurface = isDark
        ? AppTheme.darkSecondary
        : AppTheme.lightSecondary;

    final mainText = isDark
        ? AppTheme.darkMainText
        : AppTheme.lightMainText;

    final secondaryText = isDark
        ? AppTheme.darkSecondaryText
        : AppTheme.lightSecondaryText;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppTheme.lightBorder;

    final filteredTopics = widget.topics.where((topic) {
      return topic.name
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_rounded,
            color: mainText,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Text(
          widget.subject,
          style: TextStyle(
            color: mainText,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,

          // =====================================================
          // FINAL THEME BACKGROUNDS
          // =====================================================

          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF030C1D),
                    Color(0xFF0E1532),
                  ],
                )
              : AppTheme.lightBackgroundGradient,
        ),

        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // SEARCH BAR
              // =================================================

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
                    color: mainText,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),

                  cursorColor: AppTheme.primaryPurple,

                  decoration: InputDecoration(
                    hintText: 'Search topic...',

                    hintStyle: TextStyle(
                      color: secondaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryPurple,
                      size: 22,
                    ),

                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: secondaryText,
                              size: 20,
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
                    fillColor: secondarySurface,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 1.5,
                      ),
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 14,
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              // =================================================
              // TOPIC LIST
              // =================================================

              Expanded(
                child: filteredTopics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 55,
                              color: secondaryText,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'No matching topic found.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: mainText,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Try searching for another topic.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: secondaryText,
                                height: 1.3,
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
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: borderColor,
                                width: 1,
                              ),
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
                                  color: isDark
                                      ? AppTheme.darkSecondary
                                      : AppTheme.lightSecondary,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryPurple
                                        .withValues(alpha: 0.45),
                                  ),
                                ),

                                child: const Icon(
                                  Icons.account_tree_rounded,
                                  color: AppTheme.primaryPurple,
                                  size: 21,
                                ),
                              ),

                              title: Text(
                                topic.name,
                                style: TextStyle(
                                  color: mainText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),

                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: secondaryText,
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
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    final mainText = isDark
        ? AppTheme.darkMainText
        : AppTheme.lightMainText;

    final secondaryText = isDark
        ? AppTheme.darkSecondaryText
        : AppTheme.lightSecondaryText;

    // =========================================================
    // THEME-AWARE GRAPH NODE COLORS
    // =========================================================

    final prerequisiteGreen = isDark
        ? const Color(0xFF6E8F76)
        : AppTheme.prerequisiteBorder;

    final prerequisiteBackground = isDark
        ? const Color(0xFF24352B)
        : AppTheme.prerequisiteBackground;

    final prerequisiteText = isDark
        ? const Color(0xFFC4D8C9)
        : AppTheme.prerequisiteText;

    final postRequisiteOrange = isDark
        ? const Color(0xFF9B7650)
        : AppTheme.postRequisiteBorder;

    final postRequisiteBackground = isDark
        ? const Color(0xFF382C20)
        : AppTheme.postRequisiteBackground;

    final postRequisiteText = isDark
        ? const Color(0xFFD8B98F)
        : AppTheme.postRequisiteText;

    final currentTopic = AppTheme.currentTopic;

    final prerequisites = prerequisiteTopics;
    final usedIn = usedInTopics;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,

      // =======================================================
      // GRAPH SCREEN APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_rounded,
            color: mainText,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Text(
          selectedTopic.name,
          style: TextStyle(
            color: mainText,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Close',
            icon: Icon(
              Icons.close_rounded,
              color: mainText,
              size: 23,
            ),
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == '/topicList',
              );
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,

          // =====================================================
          // FINAL GRAPH BACKGROUND GRADIENT
          // =====================================================

          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF030C1D),
                    Color(0xFF0E1532),
                  ],
                )
              : AppTheme.lightBackgroundGradient,
        ),

        child: SafeArea(
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
                  lightPurple: currentTopic,
                  prerequisiteGreen: prerequisiteGreen,
                  prerequisiteBackground:
                      prerequisiteBackground,
                  prerequisiteText: prerequisiteText,
                  postRequisiteOrange:
                      postRequisiteOrange,
                  postRequisiteBackground:
                      postRequisiteBackground,
                  postRequisiteText: postRequisiteText,
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
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.primaryPurple,
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
                            selectedTopic:
                                selectedTopic,
                            subject:
                                selectedTopic.subject,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                    ),

                    label: Text(
                      'Explore ${selectedTopic.name}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'How to read: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: secondaryText,
                                height: 1.3,
                              ),
                            ),

                            _LegendItem(
                              color: prerequisiteGreen,
                              text:
                                  'Prerequisite — required concept',
                              textColor: secondaryText,
                            ),

                            const SizedBox(width: 16),

                            _LegendItem(
                              color: currentTopic,
                              text:
                                  'Current Topic — selected topic',
                              textColor: secondaryText,
                            ),

                            const SizedBox(width: 16),

                            _LegendItem(
                              color: postRequisiteOrange,
                              text:
                                  'Post requisite — where this topic is further used',
                              textColor: secondaryText,
                            ),
                          ],
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
  }
}

// =============================================================
// GRAPH AREA
// =============================================================

class _GraphArea extends StatelessWidget {
  final Topic selectedTopic;
  final List<Topic> prerequisiteTopics;
  final List<Topic> usedInTopics;

  final Color lightPurple;

  final Color prerequisiteGreen;
  final Color prerequisiteBackground;
  final Color prerequisiteText;

  final Color postRequisiteOrange;
  final Color postRequisiteBackground;
  final Color postRequisiteText;

  const _GraphArea({
    required this.selectedTopic,
    required this.prerequisiteTopics,
    required this.usedInTopics,
    required this.lightPurple,
    required this.prerequisiteGreen,
    required this.prerequisiteBackground,
    required this.prerequisiteText,
    required this.postRequisiteOrange,
    required this.postRequisiteBackground,
    required this.postRequisiteText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mainText = isDark
        ? AppTheme.darkMainText
        : AppTheme.lightMainText;

    final cardColor = isDark
        ? AppTheme.darkCard
        : AppTheme.lightCard;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppTheme.lightBorder;

    final graphLine = isDark
        ? const Color(0xFF74798F)
        : const Color(0xFF74798F);

    if (prerequisiteTopics.isEmpty &&
        usedInTopics.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree_rounded,
                size: 55,
                color: lightPurple,
              ),

              const SizedBox(height: 14),

              Text(
                selectedTopic.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: mainText,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'No directly connected topics.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppTheme.darkSecondaryText
                      : AppTheme.lightSecondaryText,
                  height: 1.35,
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
          boundaryMargin: const EdgeInsets.all(100),

          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,

            child: CustomPaint(
              painter: _PrerequisiteGraphPainter(
                prerequisiteCount:
                    prerequisiteTopics.length,
                usedInCount:
                    usedInTopics.length,
                graphLine: graphLine,
              ),

              child: Stack(
                children: [
                  // =================================================
                  // PREREQUISITES
                  // =================================================

                  ..._buildPrerequisiteNodes(
                    context,
                    constraints,
                  ),

                  // =================================================
                  // CURRENT TOPIC
                  // =================================================

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

                  // =================================================
                  // USED-IN TOPICS
                  // =================================================

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
    final bool isCurrent =
        type == _NodeType.current;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    // =========================================================
    // PREREQUISITE
    // =========================================================

    if (type == _NodeType.prerequisite) {
      backgroundColor =
          prerequisiteBackground;

      borderColor =
          prerequisiteGreen;

      textColor =
          prerequisiteText;

      // =======================================================
      // POST-REQUISITE
      // =======================================================

    } else if (type == _NodeType.usedIn) {
      backgroundColor =
          postRequisiteBackground;

      borderColor =
          postRequisiteOrange;

      textColor =
          postRequisiteText;

      // =======================================================
      // CURRENT TOPIC
      // =======================================================

    } else {
      backgroundColor =
          lightPurple;

      borderColor =
          lightPurple;

      textColor =
          Colors.white;
    }

    return Positioned(
      left: left,
      top: top,

      child: GestureDetector(
        onTap: () {
          if (topic.id == selectedTopic.id) {
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

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha: isCurrent ? 0.20 : 0.16,
                ),
                blurRadius: 8,
                offset:
                    const Offset(0, 3),
              ),
            ],
          ),

          child: Text(
            topic.name,
            textAlign: TextAlign.center,

            style: TextStyle(
              color: textColor,
              fontSize:
                  isCurrent ? 16 : 14,
              fontWeight:
                  FontWeight.w500,
              height: 1.25,
              letterSpacing: 0,
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
  final Color graphLine;

  _PrerequisiteGraphPainter({
    required this.prerequisiteCount,
    required this.usedInCount,
    required this.graphLine,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint linePaint = Paint()
      ..color = graphLine
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

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
      ..style = PaintingStyle.stroke;

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
            usedInCount ||
        oldDelegate.graphLine !=
            graphLine;
  }
}

// =============================================================
// HOW TO READ LEGEND
// =============================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}