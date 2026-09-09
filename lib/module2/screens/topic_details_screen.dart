import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';

import '../data/syllabus_data.dart';
import '../models/topic.dart';
import 'graph_screen.dart';

class TopicDetailsScreen extends StatefulWidget {
  final Topic selectedTopic;
  final String subject;

  const TopicDetailsScreen({
    super.key,
    required this.selectedTopic,
    required this.subject,
  });

  @override
  State<TopicDetailsScreen> createState() => _TopicDetailsScreenState();
}

class _TopicDetailsScreenState extends State<TopicDetailsScreen> {

// =============================================================
// AI STATES
// =============================================================

bool _isLoadingAI = false;
bool _isLoadingSummary = false;
bool _isLoadingDoubt = false;
bool _isLoadingSkip = false;
bool _isLoadingVoice = false;
bool _isVoicePlaying = false;

Duration _voiceDuration = Duration.zero;
Duration _voicePosition = Duration.zero;
int _activeLessonStage = 0;
StreamSubscription<Duration>? _positionSubscription;
StreamSubscription<Duration>? _durationSubscription;

String? _aiExplanation;
String? _aiSummary;
String? _aiDoubtAnswer;
String? _aiSkipAnswer;
Map<String, dynamic>? _aiVisualData;

// =============================================================
// AUDIO PLAYER
// =============================================================

final AudioPlayer _audioPlayer = AudioPlayer();

// =============================================================
// DOUBT CONTROLLER
// =============================================================

final TextEditingController _doubtController =
TextEditingController();

// =============================================================
// FLASK BACKEND
// =============================================================

static const String backendUrl = 'http://127.0.0.1:5000';

// =============================================================
// INIT
// =============================================================

@override
void initState() {
super.initState();


_audioPlayer.onPlayerStateChanged.listen((state) {
  if (!mounted) return;

  setState(() {
    _isVoicePlaying = state == PlayerState.playing;
  });
});

_durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
  if (!mounted) return;

  setState(() {
    _voiceDuration = duration;
  });
});

_positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
  if (!mounted) return;

  _updateActiveLessonStage(position);

  setState(() {
    _voicePosition = position;
  });
});

_audioPlayer.onPlayerComplete.listen((event) {
  if (!mounted) return;

  setState(() {
    _isVoicePlaying = false;
    _voicePosition = _voiceDuration;
    _activeLessonStage = _lessonStageCount() - 1;
  });
});


}

// =============================================================
// DISPOSE
// =============================================================

@override
void dispose() {
_positionSubscription?.cancel();
_durationSubscription?.cancel();
_doubtController.dispose();
_audioPlayer.dispose();
super.dispose();
}

// =============================================================
// AI VISUAL EXPLANATION
// =============================================================

Future<void> _startAIExplanation() async {
setState(() {
_isLoadingAI = true;
_aiExplanation = null;
_aiVisualData = null;
});


try {
  final response = await http.post(
    Uri.parse('$backendUrl/visual'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'topic': widget.selectedTopic.name,
    }),
  );

  if (!mounted) return;

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      _aiVisualData = data is Map
          ? Map<String, dynamic>.from(data)
          : null;
      _aiExplanation = _formatAIResponse(data);
      _activeLessonStage = 0;
      _voicePosition = Duration.zero;
      _voiceDuration = Duration.zero;
      _isLoadingAI = false;
    });

    // The visual lesson and the teacher voice are one lesson.
    // Voice starts from the same teacher_script returned with the visual data.
    if (_aiVisualData != null) {
      await _playVoiceExplanation();
    }
  } else {
    setState(() {
      _aiExplanation =
          'Unable to generate AI explanation.\n\n'
          'Server returned status code '
          '${response.statusCode}.';
      _isLoadingAI = false;
    });
  }
} catch (e) {
  if (!mounted) return;

  setState(() {
    _aiExplanation =
        'Could not connect to the AI Tutor.\n\n'
        'Make sure the Flask backend is running.';
    _isLoadingAI = false;
  });
}


}

// =============================================================
// AI SUMMARY
// =============================================================

Future<void> _generateAISummary() async {
setState(() {
_isLoadingSummary = true;
_aiSummary = null;
});


try {
  final response = await http.post(
    Uri.parse('$backendUrl/summary'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'topic': widget.selectedTopic.name,
    }),
  );

  if (!mounted) return;

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      _aiSummary = _formatSummaryResponse(data);
      _isLoadingSummary = false;
    });
  } else {
    setState(() {
      _aiSummary =
          'Unable to generate AI summary.\n\n'
          'Server returned status code '
          '${response.statusCode}.';
      _isLoadingSummary = false;
    });
  }
} catch (e) {
  if (!mounted) return;

  setState(() {
    _aiSummary =
        'Could not connect to the AI Tutor.\n\n'
        'Make sure the Flask backend is running.';
    _isLoadingSummary = false;
  });
}


}

// =============================================================
// AI DOUBT SOLVER
// =============================================================

Future<void> _askAIDoubt() async {
final question = _doubtController.text.trim();


if (question.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please enter a question first.',
      ),
    ),
  );
  return;
}

setState(() {
  _isLoadingDoubt = true;
  _aiDoubtAnswer = null;
});

try {
  final response = await http.post(
    Uri.parse('$backendUrl/doubt'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'topic': widget.selectedTopic.name,
      'question': question,
    }),
  );

  if (!mounted) return;

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      _aiDoubtAnswer = _formatDoubtResponse(data);
      _isLoadingDoubt = false;
    });
  } else {
    setState(() {
      _aiDoubtAnswer =
          'Unable to solve the doubt.\n\n'
          'Server returned status code '
          '${response.statusCode}.';
      _isLoadingDoubt = false;
    });
  }
} catch (e) {
  if (!mounted) return;

  setState(() {
    _aiDoubtAnswer =
        'Could not connect to the AI Tutor.\n\n'
        'Make sure the Flask backend is running.';
    _isLoadingDoubt = false;
  });
}


}

// =============================================================
// WHAT IF I SKIP
// =============================================================

Future<void> _checkWhatIfISkip() async {
setState(() {
_isLoadingSkip = true;
_aiSkipAnswer = null;
});


try {
  final response = await http.post(
    Uri.parse('$backendUrl/skip'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'topic': widget.selectedTopic.name,
    }),
  );

  if (!mounted) return;

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      _aiSkipAnswer = _formatSkipResponse(data);
      _isLoadingSkip = false;
    });
  } else {
    setState(() {
      _aiSkipAnswer =
          'Unable to analyze what happens if you skip this topic.\n\n'
          'Server returned status code '
          '${response.statusCode}.';
      _isLoadingSkip = false;
    });
  }
} catch (e) {
  if (!mounted) return;

  setState(() {
    _aiSkipAnswer =
        'Could not connect to the AI Tutor.\n\n'
        'Make sure the Flask backend is running.';
    _isLoadingSkip = false;
  });
}


}

// =============================================================
// VOICE EXPLANATION
// =============================================================

Future<void> _playVoiceExplanation() async {
  if (_isVoicePlaying) {
    await _stopVoiceExplanation();
    return;
  }

  final script = _aiVisualData?['teacher_script']?.toString().trim();

  if (script == null || script.isEmpty) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Generate the visual lesson first so the teacher voice can follow it.',
        ),
      ),
    );
    return;
  }

  setState(() {
    _isLoadingVoice = true;
    _voicePosition = Duration.zero;
    _voiceDuration = Duration.zero;
    _activeLessonStage = 0;
  });

  try {
    final response = await http.post(
      Uri.parse('$backendUrl/voice'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': widget.selectedTopic.name,
        'script': script,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Voice generation failed: ${response.statusCode}');
    }

    final Uint8List audioBytes = response.bodyBytes;

    if (audioBytes.isEmpty) {
      throw Exception('Empty audio response.');
    }

    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(audioBytes));

    if (!mounted) return;

    setState(() {
      _isLoadingVoice = false;
      _isVoicePlaying = true;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoadingVoice = false;
      _isVoicePlaying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not start the teacher voice. The visual lesson is still available.',
        ),
      ),
    );
  }
}

Future<void> _stopVoiceExplanation() async {
  await _audioPlayer.stop();

  if (!mounted) return;

  setState(() {
    _isVoicePlaying = false;
    _isLoadingVoice = false;
    _voicePosition = Duration.zero;
    _activeLessonStage = 0;
  });
}

// =============================================================
// SYNCHRONIZED LESSON STATE
// =============================================================

List<String> _lessonStageTexts() {
  final data = _aiVisualData;
  if (data == null) return [];

  final values = <String>[];

  final centralIdea = _cleanDisplayText(
    data['central_idea']?.toString() ?? '',
  );
  final analogy = _cleanDisplayText(
    data['analogy']?.toString() ?? '',
  );

  if (centralIdea.isNotEmpty) values.add(centralIdea);
  if (analogy.isNotEmpty) values.add(analogy);

  final rawSteps = data['steps'];
  if (rawSteps is List) {
    for (final item in rawSteps) {
      if (item is Map) {
        final title = _cleanDisplayText(item['title']?.toString() ?? '');
        final description = _cleanDisplayText(
          item['description']?.toString() ?? '',
        );
        values.add(
          [title, description]
              .where((value) => value.isNotEmpty)
              .join('. '),
        );
      }
    }
  }

  final example = _cleanDisplayText(data['example']?.toString() ?? '');
  final remember = _cleanDisplayText(data['remember']?.toString() ?? '');

  if (example.isNotEmpty) values.add(example);
  if (remember.isNotEmpty) values.add(remember);

  return values;
}

int _lessonStageCount() {
  final count = _lessonStageTexts().length;
  return count == 0 ? 1 : count;
}

void _updateActiveLessonStage(Duration position) {
  if (_voiceDuration <= Duration.zero) return;

  final stages = _lessonStageTexts();
  if (stages.isEmpty) return;

  final progress = (position.inMilliseconds / _voiceDuration.inMilliseconds)
      .clamp(0.0, 1.0);

  final weights = stages.map((text) {
    final words = text.split(RegExp(r'\s+')).length;
    return (words + 8).toDouble();
  }).toList();

  final totalWeight = weights.fold<double>(0, (sum, value) => sum + value);
  final target = progress * totalWeight;

  double running = 0;
  int selected = 0;

  for (int i = 0; i < weights.length; i++) {
    running += weights[i];
    if (target <= running) {
      selected = i;
      break;
    }
    selected = i;
  }

  if (selected != _activeLessonStage) {
    setState(() {
      _activeLessonStage = selected;
    });
  }
}

String _formatAIResponse(
Map<String, dynamic> data,
) {
final buffer = StringBuffer();


if (data['central_idea'] != null) {
  buffer.writeln(
    data['central_idea'].toString(),
  );
  buffer.writeln();
}

final steps = data['steps'];

if (steps is List) {
  for (int i = 0; i < steps.length; i++) {
    final step = steps[i];

    if (step is Map) {
      final title =
          step['title']?.toString() ??
              'Step ${i + 1}';

      final description =
          step['description']?.toString() ?? '';

      buffer.writeln(
        '${i + 1}. $title',
      );

      if (description.isNotEmpty) {
        buffer.writeln(description);
      }

      buffer.writeln();
    } else {
      buffer.writeln(
        '${i + 1}. ${step.toString()}',
      );
      buffer.writeln();
    }
  }
}

if (buffer.isEmpty) {
  if (data['explanation'] != null) {
    return data['explanation'].toString();
  }

  return data.toString();
}

return buffer.toString().trim();


}

// =============================================================
// FORMAT SUMMARY RESPONSE
// =============================================================

String _formatSummaryResponse(
dynamic data,
) {
if (data is String) {
return data;
}


if (data is Map<String, dynamic>) {
  final buffer = StringBuffer();

  if (data['summary'] != null) {
    final summary = data['summary'];

    if (summary is List) {
      for (int i = 0; i < summary.length; i++) {
        buffer.writeln(
          '${i + 1}. ${summary[i]}',
        );
        buffer.writeln();
      }
    } else {
      buffer.writeln(
        summary.toString(),
      );
    }
  }

  if (data['key_points'] != null) {
    buffer.writeln();
    buffer.writeln('Key Points');
    buffer.writeln();

    final keyPoints = data['key_points'];

    if (keyPoints is List) {
      for (final point in keyPoints) {
        buffer.writeln(
          'ΓÇó ${point.toString()}',
        );
      }
    } else {
      buffer.writeln(
        keyPoints.toString(),
      );
    }
  }

  if (data['important_points'] != null) {
    buffer.writeln();
    buffer.writeln('Important Points');
    buffer.writeln();

    final importantPoints =
        data['important_points'];

    if (importantPoints is List) {
      for (final point in importantPoints) {
        buffer.writeln(
          'ΓÇó ${point.toString()}',
        );
      }
    } else {
      buffer.writeln(
        importantPoints.toString(),
      );
    }
  }

  if (buffer.isEmpty) {
    if (data['explanation'] != null) {
      return data['explanation'].toString();
    }

    if (data['content'] != null) {
      return data['content'].toString();
    }

    return data.toString();
  }

  return buffer.toString().trim();
}

return data.toString();


}

// =============================================================
// FORMAT DOUBT RESPONSE
// =============================================================

String _formatDoubtResponse(
dynamic data,
) {
if (data is String) {
return data;
}


if (data is Map<String, dynamic>) {
  if (data['answer'] != null) {
    return data['answer'].toString();
  }

  if (data['response'] != null) {
    return data['response'].toString();
  }

  if (data['explanation'] != null) {
    return data['explanation'].toString();
  }

  if (data['content'] != null) {
    return data['content'].toString();
  }

  return data.toString();
}

return data.toString();


}

// =============================================================
// FORMAT SKIP RESPONSE
// =============================================================

String _formatSkipResponse(
dynamic data,
) {
if (data is String) {
return data;
}


if (data is Map<String, dynamic>) {
  final buffer = StringBuffer();

  if (data['warning'] != null) {
    buffer.writeln('Warning');
    buffer.writeln();
    buffer.writeln(
      data['warning'].toString(),
    );
    buffer.writeln();
  }

  if (data['impact'] != null) {
    buffer.writeln('Impact');
    buffer.writeln();
    buffer.writeln(
      data['impact'].toString(),
    );
    buffer.writeln();
  }

  if (data['consequences'] != null) {
    buffer.writeln('Possible Consequences');
    buffer.writeln();

    final consequences =
        data['consequences'];

    if (consequences is List) {
      for (final consequence in consequences) {
        buffer.writeln(
          'ΓÇó ${consequence.toString()}',
        );
      }
    } else {
      buffer.writeln(
        consequences.toString(),
      );
    }

    buffer.writeln();
  }

  if (data['recommendation'] != null) {
    buffer.writeln('Recommendation');
    buffer.writeln();
    buffer.writeln(
      data['recommendation'].toString(),
    );
    buffer.writeln();
  }

  if (data['explanation'] != null) {
    buffer.writeln('Explanation');
    buffer.writeln();
    buffer.writeln(
      data['explanation'].toString(),
    );
    buffer.writeln();
  }

  if (data['response'] != null) {
    buffer.writeln(
      data['response'].toString(),
    );
  }

  if (data['content'] != null) {
    buffer.writeln(
      data['content'].toString(),
    );
  }

  if (buffer.isEmpty) {
    return data.toString();
  }

  return buffer.toString().trim();
}

return data.toString();


}

// =============================================================


@override
  Widget build(BuildContext context) {
    // LearnRoot topic learning uses the team's dark navy/purple theme
    // consistently, matching the dashboard and learning-path reference.
    const isDark = true;

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
              widget.selectedTopic.prerequisites.contains(topic.id),
        )
        .toList();

    final usedInTopics = syllabusTopics
        .where(
          (topic) =>
              topic.prerequisites.contains(widget.selectedTopic.id),
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
                    count: '5 Tools',
                    mainText: mainText,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 14),

                  _buildVisualExplanationCard(),

                  const SizedBox(height: 14),

                  const SizedBox(height: 14),

                  _buildSummaryCard(),

                  const SizedBox(height: 14),

                  _buildDoubtSolverCard(),

                  const SizedBox(height: 14),

                  _buildSkipCard(),

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

// VISUAL EXPLANATION CARD
// =============================================================

Widget _buildVisualExplanationCard() {
  return _mainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.auto_awesome,
          iconColor: const Color(0xFF6C63A8),
          iconBackground: const Color(0xFFEDEBFA),
          title: 'AI Visual Lesson',
        ),
        const SizedBox(height: 8),
        const Text(
          'Watch the concept being drawn while the AI teacher explains it aloud.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Color(0xFFBDB9D8),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingAI)
          const _LessonLoadingView()
        else if (_aiVisualData != null)
          _buildVisualResult()
        else
          _buildLessonEmptyState(),
        const SizedBox(height: 16),
        _primaryButton(
          onPressed: _isLoadingAI
              ? null
              : _aiVisualData == null
                  ? _startAIExplanation
                  : _isVoicePlaying
                      ? _stopVoiceExplanation
                      : _playVoiceExplanation,
          icon: _isLoadingAI
              ? Icons.hourglass_top
              : _isVoicePlaying
                  ? Icons.pause_rounded
                  : Icons.play_circle_fill_rounded,
          label: _isLoadingAI
              ? 'Preparing lesson...'
              : _isVoicePlaying
                  ? 'Pause teacher'
                  : _aiVisualData == null
                      ? 'Start AI lesson'
                      : 'Replay teacher lesson',
        ),
      ],
    ),
  );
}

Widget _buildLessonEmptyState() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF171A38), Color(0xFF29245C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Column(
      children: [
        Icon(Icons.auto_awesome_rounded, color: Color(0xFFB9B2FF), size: 34),
        SizedBox(height: 10),
        Text(
          'Your AI teacher is ready',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'The lesson will draw the idea, highlight the important part, and explain it at the same time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD1CFF0),
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}



Widget _buildVisualResult() {
  if (_aiVisualData == null) {
    return const SizedBox.shrink();
  }
  return _buildStructuredVisualResult(_aiVisualData!);
}

Widget _buildStructuredVisualResult(Map<String, dynamic> data) {
  final topic = widget.selectedTopic.name;
  final centralIdea = _cleanDisplayText(
    data['central_idea']?.toString() ??
        'Let us understand $topic step by step.',
  );
  final analogy = _cleanDisplayText(data['analogy']?.toString() ?? '');
  final example = _cleanDisplayText(data['example']?.toString() ?? '');
  final remember = _cleanDisplayText(data['remember']?.toString() ?? '');

  final steps = <Map<String, String>>[];
  final rawSteps = data['steps'];
  if (rawSteps is List) {
    for (final item in rawSteps) {
      if (item is Map) {
        steps.add({
          'title': _cleanDisplayText(
            item['title']?.toString() ?? 'Step ${steps.length + 1}',
          ),
          'description': _cleanDisplayText(
            item['description']?.toString() ?? '',
          ),
        });
      }
    }
  }

  final stageLabels = <String>['Big idea'];
  if (analogy.isNotEmpty) stageLabels.add('Think of it');
  for (int i = 0; i < steps.length; i++) {
    stageLabels.add('Step ${i + 1}');
  }
  if (example.isNotEmpty) stageLabels.add('Example');
  if (remember.isNotEmpty) stageLabels.add('Remember');

  final activeStage = _activeLessonStage.clamp(0, stageLabels.length - 1).toInt();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLessonProgress(stageLabels, activeStage),
      const SizedBox(height: 10),
      _buildLessonCanvas(
        topic: topic,
        centralIdea: centralIdea,
        analogy: analogy,
        steps: steps,
        example: example,
        remember: remember,
        activeStage: activeStage,
      ),
    ],
  );
}

Widget _buildLessonProgress(List<String> labels, int activeStage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.record_voice_over_rounded, size: 17, color: Color(0xFF6C63A8)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              _isVoicePlaying ? 'AI teacher is explaining' : 'Lesson board',
              style: const TextStyle(
                color: Color(0xFF3B3650),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${activeStage + 1}/${labels.length}',
            style: const TextStyle(
              color: Color(0xFF777282),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          minHeight: 6,
          value: labels.isEmpty ? 0 : (activeStage + 1) / labels.length,
          backgroundColor: const Color(0xFFE8E5F1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF756BE0)),
        ),
      ),
    ],
  );
}

Widget _buildLessonCanvas({
  required String topic,
  required String centralIdea,
  required String analogy,
  required List<Map<String, String>> steps,
  required String example,
  required String remember,
  required int activeStage,
}) {
  final stageTexts = <String>[centralIdea];
  final stageTitles = <String>['🧠 Big idea'];

  if (analogy.isNotEmpty) {
    stageTexts.add(analogy);
    stageTitles.add('👀 Imagine it');
  }

  for (final step in steps) {
    stageTexts.add(
      [step['title'] ?? '', step['description'] ?? '']
          .where((value) => value.trim().isNotEmpty)
          .join('. '),
    );
    stageTitles.add('🔍 ${step['title'] ?? 'Step'}');
  }

  if (example.isNotEmpty) {
    stageTexts.add(example);
    stageTitles.add('💻 Example');
  }

  if (remember.isNotEmpty) {
    stageTexts.add(remember);
    stageTitles.add('💡 Remember');
  }

  final safeStage = activeStage.clamp(0, stageTexts.length - 1);

  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 420),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    child: Column(
      key: ValueKey<int>(safeStage),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConceptDiagram(topic),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5FD),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE1DCEF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63A8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stageTitles[safeStage],
                      style: const TextStyle(
                        color: Color(0xFF332E4B),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stageTexts[safeStage],
                      style: const TextStyle(
                        color: Color(0xFF595563),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _cleanDisplayText(String value) {
  return value
      .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
      .replaceAll('```', '')
      .replaceAll('**', '')
      .replaceAll('__', '')
      .replaceAll('##', '')
      .replaceAll('###', '')
      .replaceAll(RegExp(r'^[-•]\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

Widget _buildAIHeroCard(String topic, String centralIdea) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFF0EDFF), Color(0xFFEAF3FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFDCD7F4)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63A8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI is teaching you',
                    style: TextStyle(
                      color: Color(0xFF6C63A8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic,
                    style: const TextStyle(
                      color: Color(0xFFF7F5FF),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          '🧠 BIG IDEA',
          style: TextStyle(
            color: Color(0xFFF7F5FF),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          centralIdea,
          style: const TextStyle(
            color: Color(0xFF45425A),
            fontSize: 16,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLearningBlock({
  required IconData icon,
  required Color iconBackground,
  required Color iconColor,
  required String title,
  required String text,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE3E0F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF7F5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF555260),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStepsBlock(List<Map<String, String>> steps) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF9FF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE3E0F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔍 HOW IT WORKS',
          style: TextStyle(
            color: Color(0xFFF7F5FF),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < steps.length; i++)
          _buildStepTile(
            index: i + 1,
            title: steps[i]['title'] ?? 'Step ${i + 1}',
            description: steps[i]['description'] ?? '',
            isLast: i == steps.length - 1,
          ),
      ],
    ),
  );
}

Widget _buildStepTile({
  required int index,
  required String title,
  required String description,
  required bool isLast,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 38,
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF786DE0), Color(0xFF5A8DEE)],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFD8D3EE),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF7F5FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5B5865),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildConceptDiagram(String topic) {
  // The lesson board deliberately uses a clean, topic-specific scene instead
  // of drawing arbitrary AI nodes over one another. The AI text and teacher
  // voice still control the lesson stage; this board is the visual layer.
  return _DynamicConceptBoard(
    topic: topic,
    centralIdea: _cleanDisplayText(
      _aiVisualData?['central_idea']?.toString() ?? '',
    ),
    steps: _extractVisualSteps(),
    activeStage: _activeLessonStage,
    isVoicePlaying: _isVoicePlaying,
  );
}

List<Map<String, String>> _extractVisualSteps() {
  final result = <Map<String, String>>[];
  final raw = _aiVisualData?['steps'];
  if (raw is List) {
    for (final item in raw) {
      if (item is Map) {
        result.add({
          'title': _cleanDisplayText(item['title']?.toString() ?? ''),
          'description': _cleanDisplayText(
            item['description']?.toString() ?? '',
          ),
        });
      }
    }
  }
  return result;
}

Widget _buildAIDiagram(Map<String, dynamic> diagram) {
  final title = _cleanDisplayText(
    diagram['title']?.toString() ?? 'See how the concept works',
  );
  final subtitle = _cleanDisplayText(
    diagram['subtitle']?.toString() ?? 'The important parts are connected visually',
  );

  final rawNodes = diagram['nodes'];
  final rawConnections = diagram['connections'];

  final nodes = <Map<String, dynamic>>[];
  if (rawNodes is List) {
    for (int i = 0; i < rawNodes.length && i < 6; i++) {
      final item = rawNodes[i];
      if (item is Map) {
        nodes.add(Map<String, dynamic>.from(item));
      }
    }
  }

  if (nodes.isEmpty) {
    return _buildAnimatedGenericDiagram(widget.selectedTopic.name);
  }

  final connections = <Map<String, dynamic>>[];
  if (rawConnections is List) {
    for (final item in rawConnections) {
      if (item is Map) {
        connections.add(Map<String, dynamic>.from(item));
      }
    }
  }

  return _animatedDiagramShell(
    title: title,
    subtitle: subtitle,
    child: SizedBox(
      height: nodes.length <= 3 ? 185 : 235,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final nodeWidth = nodes.length <= 3
              ? (width - 28) / nodes.length
              : (width - 24) / 3;

          final positions = <Offset>[];
          for (int i = 0; i < nodes.length; i++) {
            if (nodes.length <= 3) {
              positions.add(
                Offset(i * (nodeWidth + 14), 55),
              );
            } else {
              final column = i % 3;
              final row = i ~/ 3;
              positions.add(
                Offset(
                  column * (nodeWidth + 12),
                  row * 105 + 28,
                ),
              );
            }
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AIDiagramConnectionPainter(
                    nodes: nodes,
                    connections: connections,
                    positions: positions,
                    nodeWidth: nodeWidth,
                    activeStage: _activeLessonStage,
                  ),
                ),
              ),
              for (int i = 0; i < nodes.length; i++)
                Positioned(
                  left: positions[i].dx,
                  top: positions[i].dy,
                  width: nodeWidth,
                  child: _buildAIDiagramNode(
                    node: nodes[i],
                    active: _isAIDiagramNodeActive(nodes[i]),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

bool _isAIDiagramNodeActive(Map<String, dynamic> node) {
  final stage = int.tryParse(node['stage']?.toString() ?? '') ?? 0;
  return stage <= _activeLessonStage;
}

Widget _buildAIDiagramNode({
  required Map<String, dynamic> node,
  required bool active,
}) {
  final label = _cleanDisplayText(
    node['label']?.toString() ?? 'Concept',
  );
  final value = _cleanDisplayText(
    node['value']?.toString() ?? '',
  );
  final caption = _cleanDisplayText(
    node['caption']?.toString() ?? '',
  );
  final kind = node['kind']?.toString().toLowerCase() ?? 'generic';

  IconData icon = Icons.widgets_rounded;
  if (kind.contains('memory')) icon = Icons.memory_rounded;
  if (kind.contains('code')) icon = Icons.code_rounded;
  if (kind.contains('process')) icon = Icons.settings_suggest_rounded;
  if (kind.contains('data')) icon = Icons.table_chart_rounded;
  if (kind.contains('person')) icon = Icons.person_rounded;
  if (kind.contains('tree')) icon = Icons.account_tree_rounded;
  if (kind.contains('input')) icon = Icons.input_rounded;
  if (kind.contains('output')) icon = Icons.output_rounded;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
    constraints: const BoxConstraints(minHeight: 78),
    padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: active
            ? const [Color(0xFF4B4A9C), Color(0xFF756BE0)]
            : const [Color(0xFF24264D), Color(0xFF30305B)],
      ),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: active
            ? const Color(0xFFA59EFF)
            : const Color(0xFF4E4D73),
        width: active ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: active
              ? const Color(0x557A6FF0)
              : const Color(0x22000000),
          blurRadius: active ? 13 : 7,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: active
              ? Colors.white
              : const Color(0xFFBDBADD),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFE5E3F2),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active
                  ? const Color(0xFFE4E0FF)
                  : const Color(0xFFAAA8C8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBDBADD),
              fontSize: 8.5,
              height: 1.15,
            ),
          ),
        ],
      ],
    ),
  );
}




Widget _animatedDiagramShell({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF12162F), Color(0xFF28245A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(21),
      boxShadow: const [
        BoxShadow(
          color: Color(0x25000000),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFF756BE0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.draw_rounded, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFBDBADD),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ],
    ),
  );
}

bool _diagramStageActive(int stage) => _activeLessonStage >= stage;

Widget _buildAnimatedPointerDiagram() {
  final stage = _activeLessonStage;
  final pointerActive = stage >= 2;
  final valueActive = stage >= 3;

  return _animatedDiagramShell(
    title: '📍 Pointer in memory',
    subtitle: 'Follow the address from the pointer to the variable',
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _animatedMemoryBox(
                label: 'Variable',
                name: 'x = 10',
                address: 'Address 1000',
                active: valueActive,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _animatedMemoryBox(
                label: 'Pointer',
                name: 'p',
                address: 'stores 1000',
                active: pointerActive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: valueActive ? 1 : 0.25,
                child: const Center(
                  child: Text(
                    '1000',
                    style: TextStyle(
                      color: Color(0xFFBDB7FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: pointerActive ? 1 : 0.25,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFFF1C76B),
                  size: 25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: pointerActive
                ? const Color(0xFF332E70)
                : const Color(0xFF24254B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: pointerActive
                  ? const Color(0xFF8D84F2)
                  : const Color(0xFF4A496D),
            ),
          ),
          child: Text(
            pointerActive
                ? 'p → address 1000 → x'
                : 'First, the pointer needs an address',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE8E6F8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _animatedMemoryBox({
  required String label,
  required String name,
  required String address,
  required bool active,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF332F70) : const Color(0xFF202246),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: active ? const Color(0xFF9A91FF) : const Color(0xFF555477),
        width: active ? 1.7 : 1,
      ),
      boxShadow: active
          ? const [BoxShadow(color: Color(0x338B82F5), blurRadius: 12)]
          : const [],
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBDB8E0),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          address,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB7B1F8),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

Widget _buildAnimatedArrayDiagram() {
  final activeIndex = (_activeLessonStage - 2).clamp(-1, 4);
  return _animatedDiagramShell(
    title: '📦 Array as memory boxes',
    subtitle: 'The highlighted position is the one the teacher is discussing',
    child: Row(
      children: List.generate(5, (index) {
        final active = index == activeIndex;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            margin: EdgeInsets.only(right: index == 4 ? 0 : 5),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF8A80F1) : const Color(0xFF24264B),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: active ? const Color(0xFFD4D0FF) : const Color(0xFF56557B),
              ),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x448B82F5), blurRadius: 10)]
                  : const [],
            ),
            child: Column(
              children: [
                Text(
                  '[$index]',
                  style: const TextStyle(
                    color: Color(0xFFC7C2EF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${[10, 25, 40, 55, 70][index]}',
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFFE4E1F3),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

Widget _buildAnimatedLinkedListDiagram() {
  final active = (_activeLessonStage - 2).clamp(0, 3);
  return _animatedDiagramShell(
    title: '🔗 Linked list as a chain',
    subtitle: 'Each node connects to the next one',
    child: Row(
      children: [
        _animatedNode('10', active == 0),
        _animatedArrow(active >= 0),
        _animatedNode('25', active == 1),
        _animatedArrow(active >= 1),
        _animatedNode('40', active == 2),
        _animatedArrow(active >= 2),
        _animatedNode('NULL', active == 3),
      ],
    ),
  );
}

Widget _animatedNode(String value, bool active) {
  return Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF766CE0) : const Color(0xFF24264B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFFD7D3FF) : const Color(0xFF57567A),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

Widget _animatedArrow(bool active) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: active ? 1 : 0.25,
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFF1C76B), size: 17),
    ),
  );
}

Widget _buildAnimatedStackDiagram() {
  final active = (_activeLessonStage - 2).clamp(0, 2);
  return _animatedDiagramShell(
    title: '🥞 Stack of plates',
    subtitle: 'The top is where push and pop happen',
    child: Column(
      children: [
        _animatedPlate('30', active == 0),
        _animatedPlate('20', active == 1),
        _animatedPlate('10', active == 2),
        const SizedBox(height: 6),
        const Text(
          'TOP  →  POP',
          style: TextStyle(color: Color(0xFFC7C3E3), fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

Widget _animatedPlate(String value, bool active) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    width: 175,
    height: 35,
    margin: const EdgeInsets.only(bottom: 4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: active
            ? const [Color(0xFF8F83F5), Color(0xFF5B86EA)]
            : const [Color(0xFF3E3C6C), Color(0xFF34345D)],
      ),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: active ? const Color(0xFFD6D1FF) : const Color(0xFF59577C),
      ),
    ),
    child: Text(
      value,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
    ),
  );
}

Widget _buildAnimatedQueueDiagram() {
  final active = (_activeLessonStage - 2).clamp(0, 3);
  return _animatedDiagramShell(
    title: '🚶 Queue of people',
    subtitle: 'First in → first out',
    child: Row(
      children: [
        const Icon(Icons.logout_rounded, color: Color(0xFFAAA6CA), size: 18),
        const SizedBox(width: 4),
        ...['A', 'B', 'C', 'D'].asMap().entries.map(
          (entry) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active == entry.key ? const Color(0xFF766CE0) : const Color(0xFF24264B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active == entry.key ? const Color(0xFFD7D3FF) : const Color(0xFF57567A),
                ),
              ),
              child: Text(
                entry.value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.login_rounded, color: Color(0xFFAAA6CA), size: 18),
      ],
    ),
  );
}

Widget _buildAnimatedTreeDiagram() {
  final active = (_activeLessonStage - 2).clamp(0, 4);
  return _animatedDiagramShell(
    title: '🌳 Tree hierarchy',
    subtitle: 'Parent nodes connect to their children',
    child: Column(
      children: [
        _animatedTreeChip('ROOT', active == 0),
        Row(
          children: [
            Expanded(child: _animatedTreeChip('LEFT', active == 1)),
            const SizedBox(width: 20),
            Expanded(child: _animatedTreeChip('RIGHT', active == 2)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _animatedTreeChip('L1', active == 3)),
            const SizedBox(width: 6),
            Expanded(child: _animatedTreeChip('L2', false)),
            const SizedBox(width: 24),
            Expanded(child: _animatedTreeChip('R1', active == 4)),
            const SizedBox(width: 6),
            Expanded(child: _animatedTreeChip('R2', false)),
          ],
        ),
      ],
    ),
  );
}

Widget _animatedTreeChip(String text, bool active) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    margin: const EdgeInsets.only(bottom: 6),
    height: 33,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF766CE0) : const Color(0xFF24264B),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: active ? const Color(0xFFD7D3FF) : const Color(0xFF57567A),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

Widget _buildAnimatedDatabaseDiagram() {
  final activeRow = (_activeLessonStage - 2).clamp(0, 3);
  final rows = [
    ['01', 'Aisha', '85'],
    ['02', 'Rahul', '91'],
    ['03', 'Sara', '88'],
  ];
  return _animatedDiagramShell(
    title: '🗃️ Database table',
    subtitle: 'Each row is one record',
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222448),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          _animatedDbRow(['ID', 'NAME', 'MARKS'], false),
          for (int i = 0; i < rows.length; i++)
            _animatedDbRow(rows[i], i == activeRow),
        ],
      ),
    ),
  );
}

Widget _animatedDbRow(List<String> values, bool active) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF5E57B0) : Colors.transparent,
      border: const Border(bottom: BorderSide(color: Color(0xFF46466A))),
    ),
    child: Row(
      children: values
          .map(
            (value) => Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFD5D2E8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

Widget _buildAnimatedOSDiagram() {
  final active = (_activeLessonStage - 2).clamp(0, 2);
  return _animatedDiagramShell(
    title: '🖥️ Operating system as a manager',
    subtitle: 'Requests travel between apps and hardware',
    child: Column(
      children: [
        _animatedOSLayer('Your Apps', Icons.apps_rounded, active == 0),
        _animatedOSArrow(active >= 0),
        _animatedOSLayer('Operating System', Icons.settings_rounded, active == 1),
        _animatedOSArrow(active >= 1),
        _animatedOSLayer('CPU  •  RAM  •  Disk', Icons.memory_rounded, active == 2),
      ],
    ),
  );
}

Widget _animatedOSLayer(String text, IconData icon, bool active) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF766CE0) : const Color(0xFF24264B),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: active ? const Color(0xFFD7D3FF) : const Color(0xFF57567A),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 17),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

Widget _animatedOSArrow(bool active) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: active ? 1 : 0.25,
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Icon(Icons.arrow_downward_rounded, color: Color(0xFFF1C76B), size: 18),
    ),
  );
}

Widget _buildAnimatedGenericDiagram(String topic) {
  final active = (_activeLessonStage - 2).clamp(0, 2);
  return _animatedDiagramShell(
    title: '🧩 Follow the concept',
    subtitle: 'The highlighted part is being explained now',
    child: Row(
      children: [
        Expanded(child: _animatedProcessBox('INPUT', active == 0)),
        _animatedArrow(active >= 0),
        Expanded(child: _animatedProcessBox(topic, active == 1)),
        _animatedArrow(active >= 1),
        Expanded(child: _animatedProcessBox('RESULT', active == 2)),
      ],
    ),
  );
}

Widget _animatedProcessBox(String text, bool active) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    height: 58,
    padding: const EdgeInsets.all(6),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF766CE0) : const Color(0xFF24264B),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: active ? const Color(0xFFD7D3FF) : const Color(0xFF57567A),
      ),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

Widget _diagramShell({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF181A35), Color(0xFF27245A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF8B82F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.draw_rounded,
                color: Colors.white,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFC8C7DD),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

Widget _buildArrayDiagram() {
  return _diagramShell(
    title: '📦 See the array in memory',
    subtitle: 'Each value gets its own numbered position',
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 4 ? 0 : 5),
                child: Column(
                  children: [
                    Text(
                      'index $index',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB9B4F5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF8C83E8),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${[10, 25, 40, 55, 70][index]}',
                        style: const TextStyle(
                          color: Color(0xFF242142),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.arrow_upward_rounded, color: Color(0xFF8B82F5), size: 18),
            SizedBox(width: 5),
            Text(
              'The computer uses the index to reach the required slot directly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE0DFF0),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildPointerDiagram() {
  return _diagramShell(
    title: '📍 See what a pointer stores',
    subtitle: 'A pointer stores an address, not the value itself',
    child: Row(
      children: [
        Expanded(child: _diagramBox('ptr', '0x1004', true)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF9D95FF)),
        ),
        Expanded(child: _diagramBox('address 0x1004', 'value = 25', false)),
      ],
    ),
  );
}

Widget _diagramBox(String title, String value, bool highlight) {
  return Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: highlight ? const Color(0xFF302C69) : const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: highlight ? const Color(0xFF8F86F5) : const Color(0xFF8F86F5),
      ),
    ),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: highlight ? Colors.white : const Color(0xFF282448),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: highlight ? const Color(0xFFBEB8FF) : const Color(0xFF514B82),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLinkedListDiagram() {
  return _diagramShell(
    title: '🔗 See the linked list as a chain',
    subtitle: 'Every node points to the next node',
    child: Row(
      children: [
        _nodeBox('10'),
        _linkArrow(),
        _nodeBox('25'),
        _linkArrow(),
        _nodeBox('40'),
        _linkArrow(),
        _nodeBox('NULL'),
      ],
    ),
  );
}

Widget _nodeBox(String value) {
  return Expanded(
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == 'NULL' ? const Color(0xFF332F67) : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8F86F5)),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: value == 'NULL' ? Colors.white : const Color(0xFF2B274A),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    ),
  );
}

Widget _linkArrow() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 3),
    child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF9D95FF), size: 18),
  );
}

Widget _buildStackDiagram() {
  return _diagramShell(
    title: '🥞 Think of a stack of plates',
    subtitle: 'The last plate placed is the first one removed',
    child: Center(
      child: Column(
        children: [
          _stackPlate('30'),
          _stackPlate('20'),
          _stackPlate('10'),
          const SizedBox(height: 7),
          const Text(
            '↑ TOP  •  POP happens here',
            style: TextStyle(color: Color(0xFFC8C7DD), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

Widget _stackPlate(String value) {
  return Container(
    width: 170,
    height: 42,
    margin: const EdgeInsets.only(bottom: 4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8C83E8), Color(0xFF5B7FE8)],
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    ),
  );
}

Widget _buildQueueDiagram() {
  return _diagramShell(
    title: '🚶 Think of a queue of people',
    subtitle: 'First in → first out',
    child: Row(
      children: [
        const RotatedBox(
          quarterTurns: 2,
          child: Icon(Icons.logout_rounded, color: Color(0xFFBDB9D8)),
        ),
        const SizedBox(width: 6),
        ...['A', 'B', 'C', 'D'].map(
          (value) => Expanded(
            child: Container(
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2B274A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.login_rounded, color: Color(0xFFBDB9D8)),
      ],
    ),
  );
}

Widget _buildTreeDiagram() {
  return _diagramShell(
    title: '🌳 See the hierarchy',
    subtitle: 'One node can lead to smaller child nodes',
    child: Column(
      children: [
        _treeNode('ROOT'),
        Row(
          children: [
            Expanded(child: _treeNode('LEFT')),
            const SizedBox(width: 35),
            Expanded(child: _treeNode('RIGHT')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _treeNode('L1')),
            const SizedBox(width: 8),
            Expanded(child: _treeNode('L2')),
            const SizedBox(width: 43),
            Expanded(child: _treeNode('R1')),
            const SizedBox(width: 8),
            Expanded(child: _treeNode('R2')),
          ],
        ),
      ],
    ),
  );
}

Widget _treeNode(String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 7),
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF8F86F5)),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Color(0xFF2B274A),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _buildDatabaseDiagram() {
  return _diagramShell(
    title: '🗃️ See data organized into tables',
    subtitle: 'Rows are records and columns describe the data',
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _dbRow(['ID', 'NAME', 'MARKS'], true),
          _dbRow(['01', 'Aisha', '85'], false),
          _dbRow(['02', 'Rahul', '91'], false),
          _dbRow(['03', 'Sara', '88'], false),
        ],
      ),
    ),
  );
}

Widget _dbRow(List<String> values, bool header) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: header ? const Color(0xFFB7B0E5) : const Color(0xFFE1DFF0)),
      ),
    ),
    child: Row(
      children: values
          .map(
            (value) => Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF2B274A),
                  fontSize: 12,
                  fontWeight: header ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

Widget _buildOSDiagram() {
  return _diagramShell(
    title: '🖥️ See the OS as the manager',
    subtitle: 'It connects applications with computer hardware',
    child: Column(
      children: [
        _osLayer('Your Apps', Icons.apps_rounded),
        const Icon(Icons.arrow_downward_rounded, color: Color(0xFF9D95FF)),
        _osLayer('Operating System', Icons.settings_rounded),
        const Icon(Icons.arrow_downward_rounded, color: Color(0xFF9D95FF)),
        _osLayer('CPU  •  RAM  •  Disk  •  Devices', Icons.memory_rounded),
      ],
    ),
  );
}

Widget _osLayer(String text, IconData icon) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF5E5794), size: 19),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2B274A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

Widget _buildGenericConceptDiagram(String topic) {
  return _diagramShell(
    title: '🧩 See the concept as a process',
    subtitle: 'Follow the idea from input to result',
    child: Row(
      children: [
        Expanded(child: _processBox('INPUT')),
        _linkArrow(),
        Expanded(child: _processBox(topic)),
        _linkArrow(),
        Expanded(child: _processBox('RESULT')),
      ],
    ),
  );
}

Widget _processBox(String text) {
  return Container(
    height: 60,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF2B274A),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _buildVisualResultFromText(String text) {
  final lines = text
      .split('\n')
      .map((line) => _cleanDisplayText(line))
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildAIHeroCard(widget.selectedTopic.name, lines.first),
      const SizedBox(height: 14),
      _buildConceptDiagram(widget.selectedTopic.name),
      for (int i = 1; i < lines.length; i++) ...[
        const SizedBox(height: 10),
        _buildLearningBlock(
          icon: Icons.school_rounded,
          iconBackground: const Color(0xFFEDEBFA),
          iconColor: const Color(0xFF6C63A8),
          title: '🔍 Step $i',
          text: lines[i],
        ),
      ],
    ],
  );
}

// =============================================================
// VOICE CARD
// =============================================================

Widget _buildVoiceCard() {
return _mainCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_cardHeader(
icon:
Icons.volume_up_rounded,
iconColor:
const Color(0xFF4D8754),
iconBackground:
const Color(0xFFE8F5E9),
title: 'Voice Explanation',
),


      const SizedBox(height: 12),

      const Text(
        'Listen to an AI-generated explanation of this topic.',
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFFBDB9D8),
        ),
      ),

      const SizedBox(height: 18),

      _greenButton(
        onPressed:
            _isLoadingVoice
                ? null
                : _playVoiceExplanation,
        icon: _isLoadingVoice
            ? Icons.hourglass_top
            : _isVoicePlaying
                ? Icons.stop_rounded
                : Icons.volume_up_rounded,
        label: _isLoadingVoice
            ? 'Generating Voice...'
            : _isVoicePlaying
                ? 'Stop Voice'
                : 'Play Voice Explanation',
      ),
    ],
  ),
);


}

// =============================================================
// SUMMARY CARD
// =============================================================

Widget _buildSummaryCard() {
return _mainCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_cardHeader(
icon:
Icons.summarize_outlined,
iconColor:
const Color(0xFF6C63A8),
iconBackground:
const Color(0xFFEDEBFA),
title: 'AI Summary',
),


      const SizedBox(height: 16),

      if (_isLoadingSummary)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF6C63A8),
                ),
                SizedBox(height: 12),
                Text(
                  'Generating AI summary...',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        )
      else if (_aiSummary != null)
        _resultContainer(
          child: Text(
            _aiSummary!,
            softWrap: true,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFFEAE7FA),
            ),
          ),
        )
      else
        const Text(
          'Generate a short AI-powered summary to quickly revise the important points of this topic.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFFBDB9D8),
          ),
        ),

      const SizedBox(height: 20),

      _primaryButton(
        onPressed:
            _isLoadingSummary
                ? null
                : _generateAISummary,
        icon: _isLoadingSummary
            ? Icons.hourglass_top
            : Icons.summarize_outlined,
        label: _isLoadingSummary
            ? 'Generating...'
            : 'Generate AI Summary',
      ),
    ],
  ),
);


}

// =============================================================
// DOUBT SOLVER CARD
// =============================================================

Widget _buildDoubtSolverCard() {
  return _mainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.psychology_rounded,
          iconColor: const Color(0xFFD8D4FF),
          iconBackground: const Color(0xFF38336F),
          title: 'AI Doubt Solver',
        ),
        const SizedBox(height: 10),
        Text(
          'Ask anything about ${widget.selectedTopic.name}. Your AI teacher will explain the answer in a simple, topic-focused way.',
          style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFBDB9D8)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF11152F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF38345F)),
          ),
          child: TextField(
            controller: _doubtController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(color: Color(0xFFF5F3FF), fontSize: 15, height: 1.45),
            cursorColor: const Color(0xFF9A8CFF),
            decoration: InputDecoration(
              hintText: '💬 Type your doubt here...',
              hintStyle: const TextStyle(color: Color(0xFF777394), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, top: 14),
                child: Icon(Icons.question_mark_rounded, color: Color(0xFF8E82F5), size: 19),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _primaryButton(
          onPressed: _isLoadingDoubt ? null : _askAIDoubt,
          icon: _isLoadingDoubt ? Icons.hourglass_top_rounded : Icons.auto_awesome_rounded,
          label: _isLoadingDoubt ? 'Thinking...' : 'Ask AI Teacher',
        ),
        if (_isLoadingDoubt)
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF9A8CFF))),
                SizedBox(width: 10),
                Text('Your AI teacher is thinking...', style: TextStyle(color: Color(0xFFBDB9D8), fontSize: 13)),
              ],
            ),
          ),
        if (_aiDoubtAnswer != null && !_isLoadingDoubt)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF201B49), Color(0xFF29235C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6256C9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: const Color(0xFF7165D9), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.smart_toy_rounded, size: 19, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('AI Teacher Answer', style: TextStyle(color: Color(0xFFF7F5FF), fontSize: 15, fontWeight: FontWeight.w800))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_aiDoubtAnswer!, softWrap: true, style: const TextStyle(color: Color(0xFFEAE7FA), fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

// =============================================================
// WHAT IF I SKIP CARD
// =============================================================

Widget _buildSkipCard() {
  return _mainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.route_rounded,
          iconColor: const Color(0xFFD8D4FF),
          iconBackground: const Color(0xFF38336F),
          title: 'What If I Skip?',
        ),
        const SizedBox(height: 10),
        Text(
          'See how skipping ${widget.selectedTopic.name} could affect the topics that come after it.',
          style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFBDB9D8)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF11152F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF38345F))),
          child: Row(
            children: [
              _skipStageIcon(Icons.play_lesson_rounded, 'Learn'),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF7066C9), size: 18),
              const SizedBox(width: 8),
              _skipStageIcon(Icons.alt_route_rounded, 'Skip'),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF7066C9), size: 18),
              const SizedBox(width: 8),
              _skipStageIcon(Icons.warning_amber_rounded, 'Impact'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingSkip)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF9A8CFF))),
              SizedBox(width: 10),
              Text('Mapping the learning impact...', style: TextStyle(color: Color(0xFFBDB9D8), fontSize: 13)),
            ]),
          )
        else if (_aiSkipAnswer != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF201B49), Color(0xFF29235C)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6256C9))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF7165D9), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 19)),
              const SizedBox(width: 12),
              Expanded(child: Text(_aiSkipAnswer!, softWrap: true, style: const TextStyle(color: Color(0xFFEAE7FA), fontSize: 14, height: 1.6))),
            ]),
          ),
        if (_aiSkipAnswer != null || _isLoadingSkip) const SizedBox(height: 16),
        _primaryButton(
          onPressed: _isLoadingSkip ? null : _checkWhatIfISkip,
          icon: _isLoadingSkip ? Icons.hourglass_top_rounded : Icons.alt_route_rounded,
          label: _isLoadingSkip ? 'Analyzing...' : 'See Learning Impact',
        ),
      ],
    ),
  );
}

Widget _skipStageIcon(IconData icon, String label) {
  return Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF302A67), borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFF6256C9))), child: Icon(icon, color: const Color(0xFFC7C1FF), size: 19)),
    const SizedBox(height: 5),
    Text(label, style: const TextStyle(color: Color(0xFFA9A5C5), fontSize: 10, fontWeight: FontWeight.w700)),
  ]));
}

// =============================================================
// COMMON MAIN CARD
// =============================================================

Widget _mainCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF171A38), Color(0xFF242052)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF343063)),
      boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x33100D2E))],
    ),
    child: child,
  );
}

Widget _cardHeader({required IconData icon, required Color iconColor, required Color iconBackground, required String title}) {
  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Container(
      width: 46, height: 46,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7165D9), Color(0xFF5549B9)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x447165D9), offset: Offset(0, 5))]),
      child: Icon(icon, color: Colors.white, size: 23),
    ),
    const SizedBox(width: 12),
    Expanded(child: Text(title, softWrap: true, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFF7F5FF), letterSpacing: -0.2))),
  ]);
}

Widget _primaryButton({required VoidCallback? onPressed, required IconData icon, required String label}) {
  return SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7165D9), disabledBackgroundColor: const Color(0xFF3B3764), foregroundColor: Colors.white, disabledForegroundColor: const Color(0xFFAAA6C5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: onPressed, icon: Icon(icon, size: 20), label: Text(label, softWrap: false, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))));
}

Widget _greenButton({required VoidCallback? onPressed, required IconData icon, required String label}) => _primaryButton(onPressed: onPressed, icon: icon, label: label);
Widget _resultContainer({required Widget child}) {
  return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF11152F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF38345F))), child: child);
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
                  widget.selectedTopic.name,
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
                        text: widget.subject,
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


class _DynamicConceptBoard extends StatelessWidget {
  final String topic;
  final String centralIdea;
  final List<Map<String, String>> steps;
  final int activeStage;
  final bool isVoicePlaying;

  const _DynamicConceptBoard({
    required this.topic,
    required this.centralIdea,
    required this.steps,
    required this.activeStage,
    required this.isVoicePlaying,
  });

  String get _name => topic.toLowerCase();

  int get _visualStep {
    if (steps.isEmpty) return 0;
    final value = activeStage - 2;
    return value.clamp(0, steps.length - 1);
  }

  String get _currentStepTitle {
    if (steps.isEmpty) return 'Watch the idea come together';
    return steps[_visualStep]['title']?.isNotEmpty == true
        ? steps[_visualStep]['title']!
        : 'Step ${_visualStep + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11152F), Color(0xFF29245E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF7468E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _boardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isVoicePlaying
                          ? 'The teacher is drawing this step now'
                          : 'Press play to watch the lesson unfold',
                      style: const TextStyle(
                        color: Color(0xFFBDB9DE),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVoicePlaying)
                const _PulsingSpeakerIcon(),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0x33100E2C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x335F59A6)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.record_voice_over_rounded,
                  color: Color(0xFFB8B0FF),
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentStepTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFEAE8FF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<String>('$_name-$_visualStep-$activeStage'),
              child: _buildScene(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _stageDot(0, 'Idea')),
              Expanded(child: _stageDot(1, 'Imagine')),
              Expanded(child: _stageDot(2, 'Build')),
              Expanded(child: _stageDot(3, 'Apply')),
            ],
          ),
        ],
      ),
    );
  }

  String get _boardTitle {
    if (_name.contains('array')) return 'Memory cells in action';
    if (_name.contains('pointer')) return 'Follow the address';
    if (_name.contains('linked list')) return 'Follow the chain';
    if (_name.contains('stack')) return 'Watch the stack change';
    if (_name.contains('queue')) return 'Watch the queue move';
    if (_name.contains('tree')) return 'Build the hierarchy';
    if (_name.contains('sort')) return 'Watch the data get sorted';
    if (_name.contains('search')) return 'Find the target';
    if (_name.contains('operator') || _name.contains('expression')) {
      return 'Build the expression';
    }
    if (_name.contains('function')) return 'Input goes through a function';
    if (_name.contains('recursion')) return 'Watch the calls stack up';
    if (_name.contains('loop') || _name.contains('iteration')) {
      return 'Watch the loop repeat';
    }
    if (_name.contains('class') || _name.contains('object') || _name.contains('inherit')) {
      return 'Turn a class into objects';
    }
    if (_name.contains('database') || _name.contains('dbms') || _name.contains('sql')) {
      return 'See data inside a table';
    }
    if (_name.contains('operating system') || _name == 'os') {
      return 'See how the OS manages everything';
    }
    return 'See $topic come alive';
  }

  Widget _stageDot(int index, String label) {
    final active = index == _stageIndex;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: active ? 9 : 7,
          height: active ? 9 : 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFFA79FFF) : const Color(0xFF5D5983),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF8581A5),
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  int get _stageIndex {
    if (activeStage <= 0) return 0;
    if (activeStage == 1) return 1;
    if (activeStage <= 4) return 2;
    return 3;
  }

  Widget _buildScene() {
    if (_name.contains('array')) return _arrayScene();
    if (_name.contains('pointer')) return _pointerScene();
    if (_name.contains('linked list') || _name.contains('linkedlist')) {
      return _linkedListScene();
    }
    if (_name.contains('stack')) return _stackScene();
    if (_name.contains('queue')) return _queueScene();
    if (_name.contains('binary tree') || _name.contains('tree')) {
      return _treeScene();
    }
    if (_name.contains('sort')) return _sortingScene();
    if (_name.contains('search')) return _searchScene();
    if (_name.contains('operator') || _name.contains('expression')) {
      return _operatorScene();
    }
    if (_name.contains('function')) return _functionScene();
    if (_name.contains('recursion')) return _recursionScene();
    if (_name.contains('loop') || _name.contains('iteration')) {
      return _loopScene();
    }
    if (_name.contains('class') || _name.contains('object') || _name.contains('inherit')) {
      return _oopScene();
    }
    if (_name.contains('database') || _name.contains('dbms') || _name.contains('sql')) {
      return _databaseScene();
    }
    if (_name.contains('operating system') || _name == 'os') {
      return _osScene();
    }
    return _genericScene();
  }

  Widget _sceneFrame({required Widget child, String? caption}) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: const Color(0x14101432),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334F4B84)),
      ),
      child: Column(
        children: [
          Expanded(child: child),
          if (caption != null) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFCBC8E6),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _labelChip(String text, {bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF756BE0) : const Color(0xFF24244C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFFA8A2FF) : const Color(0xFF49466E),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFFBEBADF),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _box(String title, String value, {bool active = false, IconData? icon}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? const [Color(0xFF4D4AA0), Color(0xFF7469E2)]
              : const [Color(0xFF25264F), Color(0xFF30305D)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? const Color(0xFFA8A1FF) : const Color(0xFF55527A),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x557C72F0),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: const Color(0xFFE7E4FF), size: 17),
          if (icon != null) const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD0CDF0),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _arrow({bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: 28,
      height: 32,
      alignment: Alignment.center,
      child: Icon(
        Icons.arrow_forward_rounded,
        color: active ? const Color(0xFFA79FFF) : const Color(0xFF65618E),
        size: active ? 23 : 19,
      ),
    );
  }

  Widget _arrayScene() {
    final activeIndex = _visualStep % 4;
    return _sceneFrame(
      caption: 'Each value has a position. The index tells us exactly which cell to access.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: i == activeIndex
                            ? const LinearGradient(
                                colors: [Color(0xFF6F65DD), Color(0xFF8A80F2)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF24264C), Color(0xFF30315C)],
                              ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: i == activeIndex
                              ? const Color(0xFFB3ADFF)
                              : const Color(0xFF4F4C76),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$i',
                            style: TextStyle(
                              color: i == activeIndex
                                  ? Colors.white
                                  : const Color(0xFF9894B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            ['45', '12', '78', '34'][i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i == activeIndex ? '← accessed' : 'cell',
                            style: TextStyle(
                              color: i == activeIndex
                                  ? const Color(0xFFE2DFFF)
                                  : const Color(0xFF777492),
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _labelChip('index $activeIndex', active: true),
              _arrow(active: true),
              _labelChip('value ${['45', '12', '78', '34'][activeIndex]}', active: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pointerScene() {
    final active = _visualStep % 3;
    return _sceneFrame(
      caption: 'A pointer does not store the value itself. It remembers where the value lives in memory.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _box('Variable', 'x = 10', active: active == 0, icon: Icons.data_object_rounded)),
          _arrow(active: active >= 1),
          Expanded(child: _box('Address', '0x1000', active: active == 1, icon: Icons.location_on_rounded)),
          _arrow(active: active >= 2),
          Expanded(child: _box('Value at address', '10', active: active == 2, icon: Icons.memory_rounded)),
        ],
      ),
    );
  }

  Widget _linkedListScene() {
    final active = _visualStep % 3;
    return _sceneFrame(
      caption: 'Each node stores data plus the link to the next node. The chain ends at NULL.',
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Expanded(
              child: _box(
                'Node ${i + 1}',
                'data: ${[10, 20, 30][i]}',
                active: i == active,
                icon: Icons.link_rounded,
              ),
            ),
            if (i < 2) _arrow(active: active > i),
          ],
          const SizedBox(width: 5),
          _labelChip('NULL', active: active == 2),
        ],
      ),
    );
  }

  Widget _stackScene() {
    final count = (_visualStep % 3) + 1;
    return _sceneFrame(
      caption: 'Stack follows LIFO: the last plate pushed is the first plate popped.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  width: 145,
                  height: 34,
                  margin: const EdgeInsets.only(bottom: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: i == count - 1
                          ? const [Color(0xFF7469E1), Color(0xFF9389FF)]
                          : const [Color(0xFF34345E), Color(0xFF45446E)],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: i == count - 1
                          ? const Color(0xFFB4AEFF)
                          : const Color(0xFF5D5A83),
                    ),
                  ),
                  child: Text(
                    'Item ${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ].reversed.toList(),
          ),
          const SizedBox(width: 22),
          _labelChip(
            _visualStep % 2 == 0 ? 'PUSH ↑' : 'POP ↑',
            active: true,
          ),
        ],
      ),
    );
  }

  Widget _queueScene() {
    final active = _visualStep % 4;
    return _sceneFrame(
      caption: 'Queue follows FIFO: the first item to enter is the first item to leave.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _labelChip('FRONT'),
              const SizedBox(width: 7),
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _box(
                      'Person ${i + 1}',
                      i == active ? 'moving' : 'waiting',
                      active: i == active,
                      icon: Icons.person_rounded,
                    ),
                  ),
                ),
              const SizedBox(width: 7),
              _labelChip('REAR'),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            active == 0 ? 'First in line → first out' : 'Everyone moves forward one place',
            style: const TextStyle(color: Color(0xFFD0CDF0), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _treeScene() {
    final active = _visualStep % 3;
    return _sceneFrame(
      caption: 'A tree starts at a root and branches into child nodes.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _box('ROOT', 'A', active: active == 0, icon: Icons.account_tree_rounded),
          const SizedBox(height: 8),
          const Icon(Icons.south_rounded, color: Color(0xFF7773A0), size: 18),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _box('LEFT CHILD', 'B', active: active == 1)),
              const SizedBox(width: 12),
              Expanded(child: _box('RIGHT CHILD', 'C', active: active == 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortingScene() {
    final swap = _visualStep % 3;
    final values = [4, 1, 3, 2];
    final sorted = [1, 2, 3, 4];
    return _sceneFrame(
      caption: 'The algorithm compares values and moves them toward their correct positions.',
      child: Row(
        children: [
          Expanded(child: _barGroup('Before', values, swap)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFA39CFF)),
          ),
          Expanded(child: _barGroup('After', sorted, 3)),
        ],
      ),
    );
  }

  Widget _barGroup(String title, List<int> values, int active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFBEBADF), fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < values.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 25.0 + values[i] * 14,
                      decoration: BoxDecoration(
                        color: i == active
                            ? const Color(0xFF8378EB)
                            : const Color(0xFF414167),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        '${values[i]}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchScene() {
    final target = _visualStep % 4;
    return _sceneFrame(
      caption: 'Searching checks candidates until the required value is found.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _box(
                      'Index $i',
                      ['12', '27', '42', '58'][i],
                      active: i == target,
                      icon: i == target ? Icons.search_rounded : Icons.crop_square_rounded,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          _labelChip(target == 2 ? 'FOUND ✓' : 'checking index $target', active: true),
        ],
      ),
    );
  }

  Widget _operatorScene() {
    final active = _visualStep % 4;
    final parts = ['5', '+', '3', '=', '8'];
    return _sceneFrame(
      caption: 'An expression combines values and operators to produce a result.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < parts.length; i++)
                _labelChip(parts[i], active: i == active),
            ],
          ),
          const SizedBox(height: 15),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _box(
              active >= 3 ? 'Result' : 'Expression',
              active >= 3 ? '8' : '5 + 3',
              active: true,
              icon: active >= 3 ? Icons.check_circle_rounded : Icons.calculate_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _functionScene() {
    final active = _visualStep % 3;
    return _sceneFrame(
      caption: 'A function takes an input, performs its defined work, and returns an output.',
      child: Row(
        children: [
          Expanded(child: _box('INPUT', '5', active: active == 0, icon: Icons.input_rounded)),
          _arrow(active: active >= 1),
          Expanded(child: _box('FUNCTION', 'double(x)', active: active == 1, icon: Icons.functions_rounded)),
          _arrow(active: active >= 2),
          Expanded(child: _box('OUTPUT', '10', active: active == 2, icon: Icons.output_rounded)),
        ],
      ),
    );
  }

  Widget _recursionScene() {
    final depth = (_visualStep % 3) + 1;
    return _sceneFrame(
      caption: 'A recursive function calls itself with a smaller problem until it reaches the base case.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < depth; i++)
                _box('call ${depth - i}', i == depth - 1 ? 'base case' : 'call again', active: i == depth - 1, icon: Icons.replay_rounded),
            ],
          ),
          const SizedBox(width: 18),
          _labelChip('return ↑', active: true),
        ],
      ),
    );
  }

  Widget _loopScene() {
    final current = (_visualStep % 4) + 1;
    return _sceneFrame(
      caption: 'A loop repeats the same block while its condition remains true.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _box('condition', current < 4 ? 'true ✓' : 'false → stop', active: true, icon: Icons.rule_rounded),
          _arrow(active: true),
          _box('iteration', 'run #$current', active: true, icon: Icons.loop_rounded),
        ],
      ),
    );
  }

  Widget _oopScene() {
    final active = _visualStep % 3;
    return _sceneFrame(
      caption: 'A class is a blueprint. Objects are real instances created from that blueprint.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _box('CLASS', 'Car blueprint', active: active == 0, icon: Icons.architecture_rounded),
          const SizedBox(height: 8),
          const Icon(Icons.south_rounded, color: Color(0xFF7773A0), size: 18),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _box('OBJECT 1', 'myCar', active: active == 1, icon: Icons.directions_car_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _box('OBJECT 2', 'yourCar', active: active == 2, icon: Icons.directions_car_filled_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _databaseScene() {
    final active = _visualStep % 3;
    final rows = [
      ['101', 'Aisha', '92'],
      ['102', 'Rahul', '87'],
      ['103', 'Zoya', '95'],
    ];
    return _sceneFrame(
      caption: 'A database stores related records in an organized structure so we can query and update them.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF24254B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF55517C)),
            ),
            child: Column(
              children: [
                _dbRow(['ID', 'NAME', 'MARKS'], active: active == 0, header: true),
                for (int i = 0; i < rows.length; i++)
                  _dbRow(rows[i], active: i == active),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _labelChip(active == 0 ? 'TABLE' : active == 1 ? 'ROW' : 'QUERY → RESULT', active: true),
        ],
      ),
    );
  }

  Widget _dbRow(List<String> values, {required bool active, bool header = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      color: active ? const Color(0x445E57C2) : Colors.transparent,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFBDB9D8),
                  fontSize: header ? 9 : 10,
                  fontWeight: header || active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _osScene() {
    final active = _visualStep % 3;
    final layers = [
      ('APPS', Icons.apps_rounded),
      ('OPERATING SYSTEM', Icons.settings_suggest_rounded),
      ('HARDWARE', Icons.memory_rounded),
    ];
    return _sceneFrame(
      caption: 'The OS acts as the manager between applications and the computer hardware.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < layers.length; i++) ...[
            _box(layers[i].$1, i == 0 ? 'Chrome • VS Code • Music' : '', active: i == active, icon: layers[i].$2),
            if (i < layers.length - 1) const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.south_rounded, color: Color(0xFF7773A0), size: 17),
            ),
          ],
        ],
      ),
    );
  }

  Widget _genericScene() {
    final active = _visualStep % 3;
    final idea = centralIdea.isEmpty ? 'Core concept' : centralIdea;
    return _sceneFrame(
      caption: 'The visual follows the teacher explanation and highlights the current learning step.',
      child: Row(
        children: [
          Expanded(child: _box('START', 'What goes in?', active: active == 0, icon: Icons.play_arrow_rounded)),
          _arrow(active: active >= 1),
          Expanded(child: _box(topic, idea, active: active == 1, icon: Icons.lightbulb_rounded)),
          _arrow(active: active >= 2),
          Expanded(child: _box('RESULT', 'What we learn', active: active == 2, icon: Icons.check_circle_rounded)),
        ],
      ),
    );
  }
}

class _PulsingSpeakerIcon extends StatefulWidget {
  const _PulsingSpeakerIcon();

  @override
  State<_PulsingSpeakerIcon> createState() => _PulsingSpeakerIconState();
}

class _PulsingSpeakerIconState extends State<_PulsingSpeakerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.88 + (_controller.value * 0.16);
        return Transform.scale(
          scale: scale,
          child: const Icon(
            Icons.volume_up_rounded,
            color: Color(0xFFAFA8FF),
            size: 21,
          ),
        );
      },
    );
  }
}

class _LessonLoadingView extends StatelessWidget {
  const _LessonLoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF171A38), Color(0xFF29245C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFFB9B2FF)),
          SizedBox(height: 12),
          Text(
            'Drawing your lesson...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'The teacher voice will follow the same lesson.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFC8C5E2), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AIDiagramConnectionPainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> connections;
  final List<Offset> positions;
  final double nodeWidth;
  final int activeStage;

  _AIDiagramConnectionPainter({
    required this.nodes,
    required this.connections,
    required this.positions,
    required this.nodeWidth,
    required this.activeStage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeHeight = nodes.length <= 3 ? 78.0 : 82.0;
    final halfWidth = nodeWidth / 2;
    final halfHeight = nodeHeight / 2;

    final idToIndex = <String, int>{};
    for (int i = 0; i < nodes.length; i++) {
      final id = nodes[i]['id']?.toString() ?? '$i';
      idToIndex[id] = i;
    }

    for (final connection in connections) {
      final from = connection['from']?.toString();
      final to = connection['to']?.toString();
      if (from == null || to == null) continue;

      final fromIndex = idToIndex[from];
      final toIndex = idToIndex[to];
      if (fromIndex == null || toIndex == null) continue;

      final fromStage =
          int.tryParse(connection['stage']?.toString() ?? '') ?? 0;
      final active = fromStage <= activeStage;

      final startCenter = positions[fromIndex] +
          Offset(halfWidth, halfHeight);
      final endCenter = positions[toIndex] +
          Offset(halfWidth, halfHeight);

      // Connect to the edge of each card, never through its center.
      final start = _edgePoint(
        startCenter,
        endCenter,
        halfWidth,
        halfHeight,
      );
      final end = _edgePoint(
        endCenter,
        startCenter,
        halfWidth,
        halfHeight,
      );

      final direction = end - start;
      final distance = direction.distance;
      if (distance < 4) continue;

      final unit = direction / distance;
      final paint = Paint()
        ..color = active
            ? const Color(0xFF9A92FF)
            : const Color(0xFF555477)
        ..strokeWidth = active ? 2.2 : 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sameRow = (startCenter.dy - endCenter.dy).abs() < 35;
      final sameColumn = (startCenter.dx - endCenter.dx).abs() < 35;
      final path = Path()..moveTo(start.dx, start.dy);
      Offset labelPoint;

      if (sameRow) {
        // Horizontal connections stay in the empty gap between cards.
        final curve = (end.dx - start.dx).abs() * 0.18;
        final directionX = end.dx >= start.dx ? 1.0 : -1.0;
        final c1 = start + Offset(curve * directionX, 0);
        final c2 = end - Offset(curve * directionX, 0);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        labelPoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2 - 13,
        );
      } else if (sameColumn) {
        final curve = (end.dy - start.dy).abs() * 0.18;
        final directionY = end.dy >= start.dy ? 1.0 : -1.0;
        final c1 = start + Offset(0, curve * directionY);
        final c2 = end - Offset(0, curve * directionY);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        labelPoint = Offset(
          (start.dx + end.dx) / 2 + 12,
          (start.dy + end.dy) / 2,
        );
      } else {
        // Route diagonal connections through the open space between rows.
        final midX = (start.dx + end.dx) / 2;
        final signY = end.dy >= start.dy ? 1.0 : -1.0;
        final bend = (end.dy - start.dy).abs() * 0.18;
        final c1 = Offset(midX, start.dy + bend * signY);
        final c2 = Offset(midX, end.dy - bend * signY);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        labelPoint = Offset(midX, (start.dy + end.dy) / 2 - 10);
      }

      canvas.drawPath(path, paint);

      // Arrowhead ends just outside the destination card.
      const arrowLength = 10.0;
      final arrowBase = end - unit * arrowLength;
      final perpendicular = Offset(-unit.dy, unit.dx);
      final p1 = arrowBase + perpendicular * 4.5;
      final p2 = arrowBase - perpendicular * 4.5;

      final arrow = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      canvas.drawPath(
        arrow,
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill,
      );

      final connectionLabel = _plain(
        connection['label']?.toString() ?? '',
      );

      if (connectionLabel.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: connectionLabel,
            style: TextStyle(
              color: active
                  ? const Color(0xFFDAD6FF)
                  : const Color(0xFF8886A7),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 72);

        final labelOffset = sameRow
            ? Offset(0, -2)
            : Offset(8, 0);

        textPainter.paint(
          canvas,
          labelPoint + labelOffset -
              Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  Offset _edgePoint(
    Offset center,
    Offset toward,
    double halfWidth,
    double halfHeight,
  ) {
    final delta = toward - center;
    if (delta.distance < 0.001) return center;

    // Find where the ray intersects the rectangular node boundary.
    final scaleX = halfWidth / delta.dx.abs();
    final scaleY = halfHeight / delta.dy.abs();
    final scale = math.min(scaleX, scaleY);
    final point = center + delta * scale;
    final unit = delta / delta.distance;

    // Leave a tiny gap so the arrowhead does not touch the card border.
    return point + unit * 4;
  }

  String _plain(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('##', '')
        .replaceAll('`', '')
        .trim();
  }

  @override
  bool shouldRepaint(covariant _AIDiagramConnectionPainter oldDelegate) {
    return oldDelegate.activeStage != activeStage ||
        oldDelegate.nodes != nodes ||
        oldDelegate.connections != connections ||
        oldDelegate.positions != positions ||
        oldDelegate.nodeWidth != nodeWidth;
  }
}

