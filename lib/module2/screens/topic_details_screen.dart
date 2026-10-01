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

  bool get _isDarkTheme => Theme.of(context).brightness == Brightness.dark;

  Color get _themeCardColor =>
      _isDarkTheme ? AppTheme.darkCard : AppTheme.lightCard;

  Color get _themeSecondarySurface =>
      _isDarkTheme ? AppTheme.darkSecondary : AppTheme.lightSecondary;

  Color get _themeMainText =>
      _isDarkTheme ? AppTheme.darkMainText : AppTheme.lightMainText;

  Color get _themeSecondaryText =>
      _isDarkTheme ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

  Color get _themeBorderColor => _isDarkTheme
      ? const Color(0xFF222D50)
      : const Color(0xFFE8E6F0);

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
final ValueNotifier<int> _lessonViewTick = ValueNotifier<int>(0);
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
final GlobalKey _visualLessonKey = GlobalKey();

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
  _refreshLessonView();
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
  _refreshLessonView();
});

_audioPlayer.onPlayerComplete.listen((event) {
  if (!mounted) return;

  setState(() {
    _isVoicePlaying = false;
    _voicePosition = _voiceDuration;
    _activeLessonStage = _lessonStageCount() - 1;
  });
  _refreshLessonView();
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
_lessonViewTick.dispose();
_audioPlayer.dispose();
super.dispose();
}

void _refreshLessonView() {
  _lessonViewTick.value++;
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
      'subject': widget.subject,
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
    _refreshLessonView();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lessonContext = _visualLessonKey.currentContext;
      if (lessonContext != null && mounted) {
        Scrollable.ensureVisible(
          lessonContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
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
      'subject': widget.subject,
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
      'subject': widget.subject,
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
      'subject': widget.subject,
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
  _refreshLessonView();

  try {
    final response = await http.post(
      Uri.parse('$backendUrl/voice'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subject': widget.subject,
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
    _refreshLessonView();
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoadingVoice = false;
      _isVoicePlaying = false;
    });
    _refreshLessonView();

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
  _refreshLessonView();
}

// =============================================================
// SYNCHRONIZED LESSON STATE
// =============================================================

List<String> _lessonStageTexts() {
  final topic = widget.selectedTopic.name.toLowerCase();

  // Pointers is the demo lesson. Keep exactly five voice/visual stages so
  // the audio timeline and the manual lesson controls stay synchronized.
  if (topic.contains('pointer')) {
    return const [
      'A variable stores a value in memory.',
      'Every variable is stored at a specific memory address.',
      'A pointer is a special variable used to store an address.',
      'Here, p stores the address 1000.',
      'Using *p lets us access the value stored at that address.',
    ];
  }

  final data = _aiVisualData;
  if (data == null) return [];

  final values = <String>[];
  final rawSteps = data['steps'];
  if (rawSteps is List) {
    for (final item in rawSteps) {
      if (item is Map) {
        final title = _cleanDisplayText(item['title']?.toString() ?? '');
        final description = _cleanDisplayText(
          item['description']?.toString() ?? '',
        );
        final text = [title, description]
            .where((value) => value.isNotEmpty)
            .join('. ');
        if (text.isNotEmpty) values.add(text);
      }
    }
  }

  if (values.isEmpty) {
    final central = _cleanDisplayText(data['central_idea']?.toString() ?? '');
    if (central.isNotEmpty) values.add(central);
  }

  return values.take(5).toList();
}

int _lessonStageCount() {
  final count = _lessonStageTexts().length;
  return count == 0 ? 1 : count;
}

void _updateActiveLessonStage(Duration position) {
  final texts = _lessonStageTexts();
  if (texts.isEmpty) return;

  final durationMs = _voiceDuration.inMilliseconds;
  final positionMs = position.inMilliseconds.clamp(0, durationMs > 0 ? durationMs : position.inMilliseconds);

  int nextStage;
  if (durationMs <= 0) {
    nextStage = _activeLessonStage.clamp(0, texts.length - 1).toInt();
  } else {
    final progress = (positionMs / durationMs).clamp(0.0, 0.999999);
    nextStage = (progress * texts.length).floor().clamp(0, texts.length - 1);
  }

  if (nextStage != _activeLessonStage && mounted) {
    setState(() {
      _activeLessonStage = nextStage;
    });
  }
}

Future<void> _setManualLessonStage(int stage) async {
  final maxStage = _lessonStageCount() - 1;
  final nextStage = stage.clamp(0, maxStage).toInt();

  // Manual navigation owns the lesson position. Pause TTS so its position
  // listener cannot immediately move the visual back to another stage.
  if (_isVoicePlaying) {
    await _audioPlayer.pause();
  }

  if (!mounted) return;

  setState(() {
    _isVoicePlaying = false;
    _isLoadingVoice = false;
    _activeLessonStage = nextStage;
  });
  _refreshLessonView();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      color: _themeSecondaryText,
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
  Widget lessonContent() {
    if (_isLoadingAI) return const _LessonLoadingView();
    if (_aiVisualData != null) return _buildVisualResult();
    return _buildLessonEmptyState();
  }

  return KeyedSubtree(
    key: _visualLessonKey,
    child: _mainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icon: Icons.smart_toy_rounded,
            iconColor: const Color(0xFF4DD0E1),
            iconBackground: const Color(0xFF172B4A),
            title: 'AI Tutor',
            onMaximize: () {
              _openAIFullscreen(
                title: 'AI Visual Lesson',
                icon: Icons.smart_toy_rounded,
                builder: () => lessonContent(),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Watch the AI teacher build the concept visually, one step at a time.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _themeSecondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // The visual lesson is the hero of this section.
          // Keep the voice action BELOW the visual, matching the other
          // AI tools instead of using a separate full-width voice bar.
          lessonContent(),

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
                    : Icons.volume_up_rounded,
            label: _isLoadingAI
                ? 'Preparing lesson...'
                : _isVoicePlaying
                    ? 'Pause teacher'
                    : _aiVisualData == null
                        ? 'Explain with Voice'
                        : 'Explain with Voice',
          ),
        ],
      ),
    ),
  );
}

Widget _buildLessonEmptyState() {
  final isDark = _isDarkTheme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _themeSecondarySurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _themeBorderColor),
    ),
    child: Column(
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: isDark ? const Color(0xFFB9B2FF) : const Color(0xFF6C63A8),
          size: 34,
        ),
        const SizedBox(height: 10),
        Text(
          'Your AI teacher is ready',
          style: TextStyle(
            color: _themeMainText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'The lesson will draw the idea, highlight the important part, and explain it at the same time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _themeSecondaryText,
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

  final stageCount = _lessonStageCount();
  final activeStage = _activeLessonStage.clamp(0, stageCount - 1).toInt();

  return _InteractiveAILesson(
    topic: topic,
    centralIdea: centralIdea,
    steps: steps,
    data: data,
    activeStage: activeStage,
    isVoicePlaying: _isVoicePlaying,
    onPrevious: activeStage == 0
        ? null
        : () => _setManualLessonStage(activeStage - 1),
    onNext: activeStage >= stageCount - 1
        ? null
        : () => _setManualLessonStage(activeStage + 1),
    onPlayPause: _aiVisualData == null
        ? _startAIExplanation
        : _isVoicePlaying
            ? _stopVoiceExplanation
            : _playVoiceExplanation,
  );
}



Widget _buildLessonProgress(List<String> labels, int activeStage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.record_voice_over_rounded,
            size: 17,
            color: Color(0xFF6C63A8),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              _isVoicePlaying ? 'AI teacher is explaining' : 'Lesson board',
              style: TextStyle(
                color: _themeMainText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${activeStage + 1}/${labels.length}',
            style: TextStyle(
              color: _themeSecondaryText,
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
          backgroundColor: _isDarkTheme
              ? const Color(0xFF303457)
              : const Color(0xFFE8E5F1),
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
  required String memoryHook,
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

  if (memoryHook.isNotEmpty) {
    stageTexts.add(memoryHook);
    stageTitles.add('🧠 Memory hook');
  }

  if (remember.isNotEmpty) {
    stageTexts.add(remember);
    stageTitles.add('💡 Remember');
  }

  final safeStage = activeStage.clamp(0, stageTexts.length - 1);
  final accentColors = <Color>[
    const Color(0xFF4DD0E1),
    const Color(0xFFFFC857),
    const Color(0xFFFF7AA2),
    const Color(0xFF9B8CFF),
    const Color(0xFF63E6BE),
  ];
  final accent = accentColors[safeStage % accentColors.length];

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
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withAlpha(145)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withAlpha(55),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
                decoration: BoxDecoration(
                  color: _isDarkTheme
                      ? const Color(0xFF171D36)
                      : const Color(0xFFF7F5FF),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: accent,
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withAlpha(25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stageTitles[safeStage],
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildColorfulExplanationText(
                      stageTexts[safeStage],
                      accent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildColorfulExplanationText(String text, Color accent) {
  final parts = text.split(RegExp(r'(\s+)'));
  const highlightWords = {
    'pointer',
    'pointers',
    'memory',
    'address',
    'variable',
    'value',
    'node',
    'array',
    'stack',
    'queue',
    'tree',
    'database',
    'class',
    'object',
    'network',
  };

  return RichText(
    text: TextSpan(
      children: [
        for (final part in parts)
          TextSpan(
            text: part,
            style: TextStyle(
              color: highlightWords.contains(
                part.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''),
              )
                  ? accent
                  : _themeSecondaryText,
              fontSize: 14,
              height: 1.55,
              fontWeight: highlightWords.contains(
                part.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''),
              )
                  ? FontWeight.w800
                  : FontWeight.w500,
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
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
      .replaceAll(RegExp(r'\s*&\s*'), ' & ')
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
  // IMPORTANT: Use the diagram generated specifically for the selected
  // subject + topic. The previous DynamicConceptBoard chose a hard-coded
  // scene from topic keywords, which caused many unrelated topics to look
  // identical.
  final diagram = _aiVisualData?['diagram'];

  if (diagram is Map) {
    return _buildAIDiagram(Map<String, dynamic>.from(diagram));
  }

  // Only use the old board as a last-resort compatibility fallback.
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
    diagram['subtitle']?.toString() ??
        'A colorful visual story of the important parts',
  );

  final rawNodes = diagram['nodes'];
  final nodes = <Map<String, dynamic>>[];
  if (rawNodes is List) {
    for (int i = 0; i < rawNodes.length && i < 6; i++) {
      final item = rawNodes[i];
      if (item is Map) {
        nodes.add(Map<String, dynamic>.from(item));
      }
    }
  }

  return _animatedDiagramShell(
    title: title,
    subtitle: subtitle,
    builder: () => SizedBox(
      height: 500,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, reveal, child) {
          return CustomPaint(
            painter: _FunVisualLessonPainter(
              topic: widget.selectedTopic.name,
              visualType:
                  diagram['visual_type']?.toString().toLowerCase() ?? '',
              nodes: nodes,
              activeStage: _activeLessonStage,
              reveal: reveal,
            ),
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
  final emoji = _cleanDisplayText(node['emoji']?.toString() ?? '');

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
        if (emoji.isNotEmpty)
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          )
        else
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
  required Widget Function() builder,
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
                color: const Color(0xFF625DB8),
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
        builder(),
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
    builder: () => Column(
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
    builder: () => Row(
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
    builder: () => Row(
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
    builder: () => Column(
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
    builder: () => Row(
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
    builder: () => Column(
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
    builder: () => Container(
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
    builder: () => Column(
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
    builder: () => Row(
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
          title: 'Lesson point',
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
icon: Icons.volume_up_rounded,
iconColor: const Color(0xFF4D8754),
iconBackground: const Color(0xFFE8F5E9),
title: 'Voice Explanation',
onMaximize: () {
  _openAIFullscreen(
    title: 'Voice Explanation',
    icon: Icons.volume_up_rounded,
    builder: () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listen to an AI-generated explanation of this topic.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: _themeSecondaryText,
          ),
        ),
        const SizedBox(height: 24),
        _greenButton(
          onPressed: _isLoadingVoice ? null : _playVoiceExplanation,
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
},
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.summarize_outlined,
          iconColor: const Color(0xFF6C63A8),
          iconBackground: const Color(0xFFEDEBFA),
          title: 'AI Summary',
          onMaximize: () {
            _openAIFullscreen(
              title: 'AI Summary',
              icon: Icons.summarize_outlined,
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoadingSummary)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF6C63A8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Generating AI summary...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _themeSecondaryText,
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
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: _themeMainText,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Generate a short AI-powered summary to quickly revise the important points of this topic.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: _themeSecondaryText,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_aiSummary == null)
                    _primaryButton(
                      onPressed: _isLoadingSummary
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
          },
        ),
        const SizedBox(height: 16),
        if (_isLoadingSummary)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF6C63A8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Generating AI summary...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _themeSecondaryText,
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
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: _themeMainText,
              ),
            ),
          )
        else
          Text(
            'Generate a short AI-powered summary to quickly revise the important points of this topic.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: _themeSecondaryText,
            ),
          ),
        if (_aiSummary == null) ...[
          const SizedBox(height: 20),
          _primaryButton(
            onPressed: _isLoadingSummary ? null : _generateAISummary,
            icon: _isLoadingSummary
                ? Icons.hourglass_top
                : Icons.summarize_outlined,
            label: _isLoadingSummary
                ? 'Generating...'
                : 'Generate AI Summary',
          ),
        ],
      ],
    ),
  );
}

Widget _buildDoubtSolverCard() {
  return _mainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.psychology_rounded,
          iconColor: _isDarkTheme
              ? const Color(0xFFD8D4FF)
              : const Color(0xFF6C63A8),
          iconBackground: _isDarkTheme
              ? const Color(0xFF38336F)
              : const Color(0xFFEDEBFA),
          title: 'AI Doubt Solver',
          onMaximize: () {
            _openAIFullscreen(
              title: 'AI Doubt Solver',
              icon: Icons.psychology_rounded,
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask anything about ${widget.selectedTopic.name}. Your AI teacher will explain the answer in a simple, topic-focused way.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: _themeSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: _themeSecondarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _themeBorderColor),
                    ),
                    child: TextField(
                      controller: _doubtController,
                      maxLines: 7,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        color: _themeMainText,
                        fontSize: 16,
                        height: 1.45,
                      ),
                      cursorColor: const Color(0xFF9A8CFF),
                      decoration: InputDecoration(
                        hintText: '💬 Type your doubt here...',
                        hintStyle: TextStyle(
                          color: _themeSecondaryText,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_aiDoubtAnswer == null)
                    _primaryButton(
                      onPressed: _isLoadingDoubt ? null : _askAIDoubt,
                      icon: _isLoadingDoubt
                          ? Icons.hourglass_top_rounded
                          : Icons.auto_awesome_rounded,
                      label: _isLoadingDoubt
                          ? 'Thinking...'
                          : 'Ask AI Teacher',
                    ),
                  if (_isLoadingDoubt)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFF9A8CFF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Your AI teacher is thinking...',
                            style: TextStyle(
                              color: _themeSecondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_aiDoubtAnswer != null && !_isLoadingDoubt)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: _resultContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7165D9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    size: 19,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'AI Teacher Answer',
                                    style: TextStyle(
                                      color: _themeMainText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _aiDoubtAnswer!,
                              softWrap: true,
                              style: TextStyle(
                                color: _themeMainText,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Ask anything about ${widget.selectedTopic.name}. Your AI teacher will explain the answer in a simple, topic-focused way.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: _themeSecondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _themeSecondarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _themeBorderColor),
          ),
          child: TextField(
            controller: _doubtController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              color: _themeMainText,
              fontSize: 15,
              height: 1.45,
            ),
            cursorColor: const Color(0xFF9A8CFF),
            decoration: InputDecoration(
              hintText: '💬 Type your doubt here...',
              hintStyle: TextStyle(
                color: _themeSecondaryText,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, top: 14),
                child: Icon(
                  Icons.question_mark_rounded,
                  color: _isDarkTheme
                      ? const Color(0xFF8E82F5)
                      : const Color(0xFF6C63A8),
                  size: 19,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ),
        if (_aiDoubtAnswer == null) ...[
          const SizedBox(height: 14),
          _primaryButton(
            onPressed: _isLoadingDoubt ? null : _askAIDoubt,
            icon: _isLoadingDoubt
                ? Icons.hourglass_top_rounded
                : Icons.auto_awesome_rounded,
            label: _isLoadingDoubt
                ? 'Thinking...'
                : 'Ask AI Teacher',
          ),
        ],
        if (_isLoadingDoubt)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF9A8CFF),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Your AI teacher is thinking...',
                  style: TextStyle(
                    color: _themeSecondaryText,
                    fontSize: 13,
                  ),
                ),
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
                color: _themeSecondarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDarkTheme
                      ? const Color(0xFF6256C9)
                      : const Color(0xFFDCD7F4),
                ),
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
                          color: const Color(0xFF7165D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Teacher Answer',
                          style: TextStyle(
                            color: _themeMainText,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _aiDoubtAnswer!,
                    softWrap: true,
                    style: TextStyle(
                      color: _themeMainText,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildSkipCard() {
  return _mainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(
          icon: Icons.route_rounded,
          iconColor: _isDarkTheme
              ? const Color(0xFFD8D4FF)
              : const Color(0xFF6C63A8),
          iconBackground: _isDarkTheme
              ? const Color(0xFF38336F)
              : const Color(0xFFEDEBFA),
          title: 'What If I Skip?',
          onMaximize: () {
            _openAIFullscreen(
              title: 'What If I Skip?',
              icon: Icons.route_rounded,
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'See how skipping ${widget.selectedTopic.name} could affect the topics that come after it.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: _themeSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _themeSecondarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _themeBorderColor),
                    ),
                    child: Row(
                      children: [
                        _skipStageIcon(Icons.play_lesson_rounded, 'Learn'),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF7066C9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        _skipStageIcon(Icons.alt_route_rounded, 'Skip'),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF7066C9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        _skipStageIcon(Icons.warning_amber_rounded, 'Impact'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_isLoadingSkip)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFF9A8CFF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Mapping the learning impact...',
                            style: TextStyle(
                              color: _themeSecondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_aiSkipAnswer != null)
                    _resultContainer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7165D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.alt_route_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _aiSkipAnswer!,
                              softWrap: true,
                              style: TextStyle(
                                color: _themeMainText,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_aiSkipAnswer == null)
                    _primaryButton(
                      onPressed: _isLoadingSkip
                          ? null
                          : _checkWhatIfISkip,
                      icon: _isLoadingSkip
                          ? Icons.hourglass_top_rounded
                          : Icons.alt_route_rounded,
                      label: _isLoadingSkip
                          ? 'Analyzing...'
                          : 'See Learning Impact',
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          'See how skipping ${widget.selectedTopic.name} could affect the topics that come after it.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: _themeSecondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _themeSecondarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _themeBorderColor),
          ),
          child: Row(
            children: [
              _skipStageIcon(Icons.play_lesson_rounded, 'Learn'),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF7066C9),
                size: 18,
              ),
              const SizedBox(width: 8),
              _skipStageIcon(Icons.alt_route_rounded, 'Skip'),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF7066C9),
                size: 18,
              ),
              const SizedBox(width: 8),
              _skipStageIcon(Icons.warning_amber_rounded, 'Impact'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingSkip)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF9A8CFF),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Mapping the learning impact...',
                  style: TextStyle(
                    color: _themeSecondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else if (_aiSkipAnswer != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeSecondarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDarkTheme
                    ? const Color(0xFF6256C9)
                    : const Color(0xFFDCD7F4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7165D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _aiSkipAnswer!,
                    softWrap: true,
                    style: TextStyle(
                      color: _themeMainText,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_aiSkipAnswer != null || _isLoadingSkip)
          const SizedBox(height: 16),
        if (_aiSkipAnswer == null)
          _primaryButton(
            onPressed: _isLoadingSkip ? null : _checkWhatIfISkip,
            icon: _isLoadingSkip
                ? Icons.hourglass_top_rounded
                : Icons.alt_route_rounded,
            label: _isLoadingSkip
                ? 'Analyzing...'
                : 'See Learning Impact',
          ),
      ],
    ),
  );
}

Widget _skipStageIcon(IconData icon, String label) {
  return Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _isDarkTheme
                ? const Color(0xFF302A67)
                : const Color(0xFFEDEBFA),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _isDarkTheme
                  ? const Color(0xFF6256C9)
                  : const Color(0xFFDCD7F4),
            ),
          ),
          child: Icon(
            icon,
            color: _isDarkTheme
                ? const Color(0xFFC7C1FF)
                : const Color(0xFF6C63A8),
            size: 19,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: _themeSecondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

// =============================================================
// FULLSCREEN AI FEATURE
// =============================================================

void _openAIFullscreen({
  required String title,
  required IconData icon,
  required Widget Function() builder,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (fullscreenContext) {
        return Scaffold(
          backgroundColor: _themeCardColor,
          appBar: AppBar(
            backgroundColor: _themeCardColor,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Close',
              icon: Icon(
                Icons.close_rounded,
                color: _themeMainText,
              ),
              onPressed: () {
                Navigator.of(fullscreenContext).pop();
              },
            ),
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7165D9),
                        Color(0xFF5549B9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _themeMainText,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: ValueListenableBuilder<int>(
                valueListenable: _lessonViewTick,
                builder: (context, _, __) => builder(),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// =============================================================
// COMMON MAIN CARD
// =============================================================

Widget _mainCard({required Widget child}) {
  // Keep the cards aligned with the full content area. The page already
  // provides its own horizontal padding, so don't add a desktop max-width
  // here. This keeps every AI card consistently wide on large screens.
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _themeCardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _themeBorderColor),
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          offset: const Offset(0, 8),
          color: _isDarkTheme
              ? const Color(0x33100D2E)
              : const Color(0x14000000),
        ),
      ],
    ),
    child: child,
  );
}

Widget _cardHeader({
  required IconData icon,
  required Color iconColor,
  required Color iconBackground,
  required String title,
  VoidCallback? onMaximize,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7165D9), Color(0xFF5549B9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x447165D9),
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 23),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          softWrap: true,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _themeMainText,
            letterSpacing: -0.2,
          ),
        ),
      ),
      if (onMaximize != null)
        IconButton(
          tooltip: 'Open fullscreen',
          onPressed: onMaximize,
          icon: Icon(
            Icons.open_in_full_rounded,
            color: _themeSecondaryText,
            size: 22,
          ),
        ),
    ],
  );
}

Widget _primaryButton({
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
}) {
  return Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7165D9),
            disabledBackgroundColor: const Color(0xFF3B3764),
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFFAAA6C5),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _greenButton({required VoidCallback? onPressed, required IconData icon, required String label}) => _primaryButton(onPressed: onPressed, icon: icon, label: label);
Widget _resultContainer({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _themeSecondarySurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _themeBorderColor),
    ),
    child: child,
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
                          color: _themeSecondaryText,
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
                    color: _themeSecondaryText,
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
                  color: _themeSecondaryText,
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
                          color: _themeSecondaryText,
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
                  color: _themeSecondaryText,
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

  @override
  Widget build(BuildContext context) {
    final stepIndex = steps.isEmpty
        ? 0
        : (activeStage - 2).clamp(0, steps.length - 1);
    final stepTitle = steps.isEmpty
        ? 'Concept in action'
        : (steps[stepIndex]['title']?.trim().isNotEmpty == true
            ? steps[stepIndex]['title']!.trim()
            : 'Step ${stepIndex + 1}');

    return Container(
      width: double.infinity,
      height: 360,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1228), Color(0xFF211D4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x335E58A4)),
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
                      topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFBEB9E4),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVoicePlaying)
                const _PulsingSpeakerIcon(),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(
                painter: _FallbackConceptPainter(
                  topic: topic,
                  centralIdea: centralIdea,
                  activeStage: activeStage,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackConceptPainter extends CustomPainter {
  final String topic;
  final String centralIdea;
  final int activeStage;

  const _FallbackConceptPainter({
    required this.topic,
    required this.centralIdea,
    required this.activeStage,
  });

  String get _name => topic.toLowerCase();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF0A0E20);
    canvas.drawRect(Offset.zero & size, background);

    final titlePaint = Paint()
      ..color = const Color(0xFF5D59A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        const Radius.circular(18),
      ),
      titlePaint,
    );

    if (_name.contains('array')) {
      _paintArray(canvas, size);
    } else if (_name.contains('pointer')) {
      _paintPointer(canvas, size);
    } else if (_name.contains('linked list') || _name.contains('linkedlist')) {
      _paintLinkedList(canvas, size);
    } else if (_name.contains('stack')) {
      _paintStack(canvas, size);
    } else if (_name.contains('queue')) {
      _paintQueue(canvas, size);
    } else if (_name.contains('tree')) {
      _paintTree(canvas, size);
    } else if (_name.contains('sort')) {
      _paintSorting(canvas, size);
    } else if (_name.contains('search')) {
      _paintSearch(canvas, size);
    } else if (_name.contains('operator') || _name.contains('expression')) {
      _paintExpression(canvas, size);
    } else if (_name.contains('function')) {
      _paintFunction(canvas, size);
    } else if (_name.contains('recursion')) {
      _paintRecursion(canvas, size);
    } else if (_name.contains('loop') || _name.contains('iteration')) {
      _paintLoop(canvas, size);
    } else if (_name.contains('class') || _name.contains('object') || _name.contains('inherit')) {
      _paintOop(canvas, size);
    } else if (_name.contains('database') || _name.contains('dbms') || _name.contains('sql')) {
      _paintDatabase(canvas, size);
    } else if (_name.contains('operating system') || _name == 'os') {
      _paintOs(canvas, size);
    } else {
      _paintConcept(canvas, size);
    }

    _paintFooter(canvas, size);
  }

  void _paintArray(Canvas canvas, Size size) {
    final y = size.height * 0.48;
    final cellW = (size.width - 70) / 5;
    for (var i = 0; i < 5; i++) {
      final x = 35 + i * cellW;
      _cell(canvas, Rect.fromLTWH(x, y, cellW - 5, 58), '${i + 10}', i == activeStage % 5);
      _text(canvas, '[${i}]', Offset(x + (cellW - 5) / 2, y - 19), 10, const Color(0xFF8984B4), center: true);
    }
    _arrow(canvas, Offset(35, y + 86), Offset(size.width - 35, y + 86));
    _text(canvas, 'contiguous memory', Offset(size.width / 2, y + 104), 11, const Color(0xFFB9B4DA), center: true);
  }

  void _paintPointer(Canvas canvas, Size size) {
    final left = Offset(size.width * 0.22, size.height * 0.43);
    final right = Offset(size.width * 0.70, size.height * 0.43);
    _cell(canvas, Rect.fromCenter(center: left, width: 120, height: 68), 'x = 10', true);
    _circle(canvas, right, 42, '0x1004');
    _arrow(canvas, Offset(left.dx + 65, left.dy), Offset(right.dx - 47, right.dy));
    _text(canvas, 'pointer', Offset((left.dx + right.dx) / 2, left.dy - 22), 11, const Color(0xFFBDB8E0), center: true);
    _text(canvas, 'address', Offset(right.dx, right.dy + 58), 10, const Color(0xFF8581A9), center: true);
  }

  void _paintLinkedList(Canvas canvas, Size size) {
    final y = size.height * 0.44;
    final values = ['10', '20', '30', 'NULL'];
    for (var i = 0; i < values.length; i++) {
      final x = 55 + i * ((size.width - 130) / 3);
      _cell(canvas, Rect.fromLTWH(x, y, 78, 62), values[i], i == activeStage % 3);
      if (i < values.length - 1) {
        _arrow(canvas, Offset(x + 84, y + 31), Offset(x + 112, y + 31));
      }
    }
    _text(canvas, 'next → next → next', Offset(size.width / 2, y + 84), 11, const Color(0xFFAAA5CC), center: true);
  }

  void _paintStack(Canvas canvas, Size size) {
    final x = size.width / 2 - 55;
    final bottom = size.height * 0.76;
    final values = ['A', 'B', 'C'];
    for (var i = 0; i < values.length; i++) {
      final y = bottom - i * 53;
      _cell(canvas, Rect.fromLTWH(x, y, 110, 45), values[i], i == activeStage % 3);
    }
    _arrow(canvas, Offset(x + 140, bottom - 80), Offset(x + 140, bottom - 150));
    _text(canvas, activeStage.isEven ? 'PUSH' : 'POP', Offset(x + 160, bottom - 160), 11, const Color(0xFFBDB8E0), center: true);
  }

 void _paintQueue(Canvas canvas, Size size) {
  final double y = size.height * 0.45;

  final values = ['A', 'B', 'C', 'D'];

  for (var i = 0; i < values.length; i++) {
    final double x = 35.0 + i * 78.0;

    _cell(
      canvas,
      Rect.fromLTWH(
        x,
        y,
        68.0,
        52.0,
      ),
      values[i],
      i == activeStage % 4,
    );
  }

  _arrow(
    canvas,
    Offset(20.0, y + 26.0),
    Offset(34.0, y + 26.0),
  );

  _arrow(
    canvas,
    Offset(size.width - 34.0, y + 26.0),
    Offset(size.width - 20.0, y + 26.0),
  );

  _text(
    canvas,
    'FRONT',
    Offset(48.0, y - 18.0),
    9.0,
    const Color(0xFF9A95BA),
    center: true,
  );

  _text(
    canvas,
    'REAR',
    Offset(size.width - 48.0, y - 18.0),
    9.0,
    const Color(0xFF9A95BA),
    center: true,
  );
}

  void _paintTree(Canvas canvas, Size size) {
    final root = Offset(size.width / 2, size.height * 0.27);
    final l = Offset(size.width * 0.30, size.height * 0.52);
    final r = Offset(size.width * 0.70, size.height * 0.52);
    final ll = Offset(size.width * 0.18, size.height * 0.76);
    final lr = Offset(size.width * 0.42, size.height * 0.76);
    final rl = Offset(size.width * 0.58, size.height * 0.76);
    final rr = Offset(size.width * 0.82, size.height * 0.76);
    _line(canvas, root, l); _line(canvas, root, r);
    _line(canvas, l, ll); _line(canvas, l, lr);
    _line(canvas, r, rl); _line(canvas, r, rr);
    _circle(canvas, root, 24, '8');
    _circle(canvas, l, 21, '4'); _circle(canvas, r, 21, '12');
    _circle(canvas, ll, 18, '2'); _circle(canvas, lr, 18, '6');
    _circle(canvas, rl, 18, '10'); _circle(canvas, rr, 18, '14');
  }

  void _paintSorting(Canvas canvas, Size size) {
    final base = size.height * 0.79;
    final values = [0.28, 0.55, 0.42, 0.82, 0.64, 0.38];
    for (var i = 0; i < values.length; i++) {
      final h = size.height * 0.50 * values[i];
      final x = 30 + i * 48;
      final active = i == activeStage % values.length || i == (activeStage + 1) % values.length;
      final paint = Paint()..color = active ? const Color(0xFFA69FFF) : const Color(0xFF57527F);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
  Rect.fromLTWH(x.toDouble(), base - h, 34.0, h),
  const Radius.circular(7),
),
        paint,
      );
      _text(canvas, '${(values[i] * 10).round()}', Offset(x + 17, base + 12), 9, const Color(0xFFAAA5C8), center: true);
    }
    _text(canvas, 'compare → swap → repeat', Offset(size.width / 2, 22), 11, const Color(0xFFBDB8E0), center: true);
  }

 void _paintSearch(Canvas canvas, Size size) {
  final double y = size.height * 0.47;

  final values = ['4', '7', '9', '12', '18'];
  final target = activeStage % values.length;

  for (var i = 0; i < values.length; i++) {
    final double x = 28.0 + i * 66.0;

    _cell(
      canvas,
      Rect.fromLTWH(
        x,
        y,
        55.0,
        52.0,
      ),
      values[i],
      i == target,
    );
  }

  final double targetX = 28.0 + target * 66.0 + 27.0;

  _arrow(
    canvas,
    Offset(targetX, y - 38.0),
    Offset(targetX, y - 7.0),
  );

  _text(
    canvas,
    'target',
    Offset(targetX, y - 54.0),
    10.0,
    const Color(0xFFBDB8E0),
    center: true,
  );
}

  void _paintExpression(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    _cell(canvas, Rect.fromCenter(center: center, width: 100, height: 58), '+', true);
    _circle(canvas, Offset(center.dx - 92, center.dy), 30, 'A');
    _circle(canvas, Offset(center.dx + 92, center.dy), 30, 'B');
    _arrow(canvas, Offset(center.dx - 62, center.dy), Offset(center.dx - 51, center.dy));
    _arrow(canvas, Offset(center.dx + 51, center.dy), Offset(center.dx + 62, center.dy));
    _text(canvas, 'operand', Offset(center.dx - 92, center.dy + 48), 9, const Color(0xFF8C88AE), center: true);
    _text(canvas, 'operand', Offset(center.dx + 92, center.dy + 48), 9, const Color(0xFF8C88AE), center: true);
  }

  void _paintFunction(Canvas canvas, Size size) {
    final y = size.height * 0.48;
    _cell(canvas, Rect.fromLTWH(28, y, 92, 58), 'input', true);
    _cell(canvas, Rect.fromLTWH(size.width / 2 - 60, y, 120, 58), 'f(x)', activeStage % 2 == 0);
    _cell(canvas, Rect.fromLTWH(size.width - 120, y, 92, 58), 'output', activeStage % 2 == 1);
    _arrow(canvas, Offset(122, y + 29), Offset(size.width / 2 - 63, y + 29));
    _arrow(canvas, Offset(size.width / 2 + 63, y + 29), Offset(size.width - 123, y + 29));
  }

  void _paintRecursion(Canvas canvas, Size size) {
    final x = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final w = 150.0 - i * 28;
      final y = 42 + i * 57.0;
      _cell(canvas, Rect.fromLTWH(x - w / 2, y, w, 42), 'call ${i + 1}', i == activeStage % 3);
    }
    _text(canvas, 'base case ends the calls', Offset(x, size.height - 42), 10, const Color(0xFFAAA5C8), center: true);
  }

  void _paintLoop(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.22, size.height * 0.25, size.width * 0.56, size.height * 0.46);
    final paint = Paint()
      ..color = const Color(0xFF7468E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(26)), paint);
    _arrow(canvas, Offset(rect.right, rect.center.dy), Offset(rect.right - 2, rect.top + 30));
    _text(canvas, 'condition?', rect.topLeft + const Offset(12, 22), 11, const Color(0xFFBDB8E0));
    _text(canvas, 'repeat', rect.center, 14, const Color(0xFFD6D2F3), center: true);
  }

  void _paintOop(Canvas canvas, Size size) {
    final classCenter = Offset(size.width * 0.30, size.height * 0.48);
    final objectCenter = Offset(size.width * 0.70, size.height * 0.48);
    _cell(canvas, Rect.fromCenter(center: classCenter, width: 135, height: 90), 'Class');
    _cell(canvas, Rect.fromCenter(center: objectCenter, width: 135, height: 90), 'Object', true);
    _arrow(canvas, Offset(classCenter.dx + 70, classCenter.dy), Offset(objectCenter.dx - 70, objectCenter.dy));
    _text(canvas, 'creates', Offset(size.width / 2, classCenter.dy - 20), 10, const Color(0xFFAAA5C8), center: true);
  }

  void _paintDatabase(Canvas canvas, Size size) {
    final x = size.width * 0.50;
    final y = size.height * 0.48;
    _cell(canvas, Rect.fromCenter(center: Offset(x, y), width: 160, height: 60), 'TABLE', true);
    for (var i = 0; i < 3; i++) {
      final yy = y - 70 + i * 140;
      _cell(canvas, Rect.fromLTWH(22, yy, 86, 42), 'row ${i + 1}', i == activeStage % 3);
      _arrow(canvas, Offset(110, yy + 21), Offset(x - 82, y));
    }
    _text(canvas, 'rows + columns', Offset(x, y + 48), 10, const Color(0xFFAAA5C8), center: true);
  }

  void _paintOs(Canvas canvas, Size size) {
    final x = size.width / 2;
    final layers = ['Applications', 'Operating System', 'Hardware'];
    for (var i = 0; i < layers.length; i++) {
      final w = 210.0 - i * 45;
      final y = 42 + i * 62.0;
      _cell(canvas, Rect.fromLTWH(x - w / 2, y, w, 46), layers[i], i == activeStage % 3);
      if (i < layers.length - 1) {
        _arrow(canvas, Offset(x, y + 50), Offset(x, y + 59));
      }
    }
  }

  void _paintConcept(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final idea = centralIdea.trim().isEmpty ? 'core idea' : _short(centralIdea, 28);
    _circle(canvas, center, 48, 'IDEA');
    final points = [
      Offset(size.width * 0.22, size.height * 0.28),
      Offset(size.width * 0.78, size.height * 0.28),
      Offset(size.width * 0.22, size.height * 0.70),
      Offset(size.width * 0.78, size.height * 0.70),
    ];
    for (var i = 0; i < points.length; i++) {
      _line(canvas, center, points[i]);
      _circle(canvas, points[i], 27, '${i + 1}');
    }
    _text(canvas, idea, Offset(center.dx, center.dy + 67), 10, const Color(0xFFBDB8E0), center: true);
  }

  void _paintFooter(Canvas canvas, Size size) {
    final text = centralIdea.trim().isEmpty
        ? 'AI visual fallback'
        : _short(centralIdea, 58);
    _text(canvas, text, Offset(size.width / 2, size.height - 17), 9.5, const Color(0xFF77739A), center: true);
  }

  void _cell(Canvas canvas, Rect rect, String label, [bool active = false]) {
    final fill = Paint()..color = active ? const Color(0xFF655FD0) : const Color(0xFF25264B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      fill,
    );
    final border = Paint()
      ..color = active ? const Color(0xFFB0AAFF) : const Color(0xFF4E4B78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      border,
    );
    _text(canvas, label, rect.center, 11, Colors.white, center: true);
  }

  void _circle(Canvas canvas, Offset center, double radius, String label) {
    final fill = Paint()..color = const Color(0xFF282950);
    canvas.drawCircle(center, radius, fill);
    final border = Paint()
      ..color = const Color(0xFF8079E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);
    _text(canvas, label, center, radius < 20 ? 9 : 10.5, Colors.white, center: true);
  }

  void _line(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = const Color(0xFF625E91)
        ..strokeWidth = 2,
    );
  }

  void _arrow(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = const Color(0xFF8C86E9)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
    final direction = end - start;
    final length = direction.distance;
    if (length < 1) return;
    final unit = direction / length;
    final side = Offset(-unit.dy, unit.dx);
    final base = end - unit * 9;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo((base + side * 4).dx, (base + side * 4).dy)
      ..lineTo((base - side * 4).dx, (base - side * 4).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF8C86E9));
  }

  void _text(
    Canvas canvas,
    String value,
    Offset position,
    double fontSize,
    Color color, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 190);
    final offset = center
        ? position - Offset(painter.width / 2, painter.height / 2)
        : position;
    painter.paint(canvas, offset);
  }

  String _short(String value, int maxLength) {
    final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxLength) return clean;
    return '${clean.substring(0, maxLength - 1)}…';
  }

  @override
  bool shouldRepaint(covariant _FallbackConceptPainter oldDelegate) {
    return oldDelegate.topic != topic ||
        oldDelegate.centralIdea != centralIdea ||
        oldDelegate.activeStage != activeStage;
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


class _FunVisualLessonPainter extends CustomPainter {
  final String topic;
  final String visualType;
  final List<Map<String, dynamic>> nodes;
  final int activeStage;
  final double reveal;

  _FunVisualLessonPainter({
    required this.topic,
    required this.visualType,
    required this.nodes,
    required this.activeStage,
    required this.reveal,
  });

  final List<Color> _palette = const [
    Color(0xFF4DD0E1),
    Color(0xFFFFC857),
    Color(0xFFFF7AA2),
    Color(0xFF9B8CFF),
    Color(0xFF63E6BE),
    Color(0xFFFF9F43),
  ];

  String _clean(String value) {
    return value
        .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
        .replaceAll('```', '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('##', '')
        .replaceAll('###', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _label(Map<String, dynamic> node) =>
      _clean(node['label']?.toString() ?? 'Concept');

  String _value(Map<String, dynamic> node) =>
      _clean(node['value']?.toString() ?? '');

  String _caption(Map<String, dynamic> node) =>
      _clean(node['caption']?.toString() ?? '');

  bool _active(Map<String, dynamic> node) {
    final stage = int.tryParse(node['stage']?.toString() ?? '') ?? 0;
    return stage <= activeStage;
  }

  void _text(
    Canvas canvas,
    String value,
    Offset center,
    TextStyle style, {
    double maxWidth = 150,
    int maxLines = 2,
  }) {
    if (value.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }

  void _star(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final radius = i.isEven ? size : size * .28;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _glow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color.withAlpha(45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawTag(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    double width = 92,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: 36),
      const Radius.circular(14),
    );
    canvas.drawRRect(rect, Paint()..color = color.withAlpha(42));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withAlpha(150),
    );
    _text(
      canvas,
      text,
      center,
      TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      maxWidth: width - 10,
      maxLines: 1,
    );
  }

  void _drawMemoryBlock(
    Canvas canvas,
    Offset center,
    Size size,
    String label,
    String value,
    String caption,
    Color color,
    bool active,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      const Radius.circular(16),
    );

    if (active) _glow(canvas, center, size.width * .35, color);

    final fill = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withAlpha(active ? 72 : 35),
          const Color(0xFF18213E).withAlpha(230),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect.outerRect);

    canvas.drawRRect(rect, fill);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.2 : 1.1
        ..color = color.withAlpha(active ? 230 : 100),
    );

    _text(
      canvas,
      label,
      center.translate(0, -25),
      TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
      maxWidth: size.width - 12,
      maxLines: 1,
    );

    _text(
      canvas,
      value.isEmpty ? '—' : value,
      center.translate(0, 2),
      const TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w900,
      ),
      maxWidth: size.width - 12,
      maxLines: 1,
    );

    _text(
      canvas,
      caption,
      center.translate(0, 27),
      const TextStyle(
        color: Color(0xFFAEB7D6),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: size.width - 10,
      maxLines: 1,
    );
  }

  void _arrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color, {
    String label = '',
  }) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance < 2) return;

    final unit = delta / distance;
    final end = to - unit * 7;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(from, end, paint);

    final perpendicular = Offset(-unit.dy, unit.dx);
    final p1 = end - unit * 10 + perpendicular * 5;
    final p2 = end - unit * 10 - perpendicular * 5;

    final arrow = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(arrow, Paint()..color = color);

    if (label.isNotEmpty) {
      _drawTag(
        canvas,
        label,
        (from + to) / 2 + perpendicular * 16,
        color,
        width: 105,
      );
    }
  }

  void _drawPointer(Canvas canvas, Size size) {
    final pointer = nodes.isNotEmpty
        ? nodes[0]
        : <String, dynamic>{
            'label': 'Pointer p',
            'value': '1000',
            'caption': 'stores address',
            'stage': 0,
          };
    final variable = nodes.length > 1
        ? nodes[1]
        : <String, dynamic>{
            'label': 'Variable x',
            'value': '10',
            'caption': 'memory address 1000',
            'stage': 1,
          };

    final left = Offset(size.width * .27, size.height * .51);
    final right = Offset(size.width * .73, size.height * .51);
    final pointerColor = _palette[3];
    final variableColor = _palette[0];

    final blockWidth = math.min(260.0, math.max(180.0, size.width * .22));
    final blockHeight = math.min(165.0, math.max(130.0, size.height * .32));

    _drawMemoryBlock(
      canvas,
      left,
      Size(blockWidth, blockHeight),
      _label(variable),
      _value(variable).isEmpty ? '10' : _value(variable),
      'ADDRESS 1000',
      variableColor,
      _active(variable),
    );

    _drawMemoryBlock(
      canvas,
      right,
      Size(blockWidth, blockHeight),
      _label(pointer),
      _value(pointer).isEmpty ? '1000' : _value(pointer),
      'p → x',
      pointerColor,
      _active(pointer),
    );

    _arrow(
      canvas,
      left + const Offset(64, 0),
      right - const Offset(64, 0),
      _palette[1],
      label: 'points to',
    );

    _drawTag(
      canvas,
      'x = 10',
      Offset(left.dx, size.height * .20),
      variableColor,
      width: 78,
    );
    _drawTag(
      canvas,
      'p stores address',
      Offset(right.dx, size.height * .20),
      pointerColor,
      width: 112,
    );

    _text(
      canvas,
      'One variable • one address • one connection',
      Offset(size.width / 2, size.height * .88),
      const TextStyle(
        color: Color(0xFFC4CBE4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: size.width - 24,
      maxLines: 1,
    );
  }

  void _drawGeneric(Canvas canvas, Size size) {
    // Large colorful concept bubbles keep text readable in fullscreen.
    final center = Offset(size.width / 2, size.height * .52);
    final count = math.min(nodes.length, 5);
    final nodeRadius = math.min(64.0, math.max(50.0, size.width * .035));
    final positions = <Offset>[
      Offset(size.width * .18, size.height * .27),
      Offset(size.width * .82, size.height * .27),
      Offset(size.width * .15, size.height * .75),
      Offset(size.width * .85, size.height * .75),
      Offset(size.width * .50, size.height * .13),
    ];

    _glow(canvas, center, 92, _palette[3]);

    for (int i = 0; i < count; i++) {
      final node = nodes[i];
      final color = _palette[i % _palette.length];
      final pos = positions[i];
      final active = _active(node);
      final value = _value(node);
      final caption = _caption(node);
      final direction = center - pos;
      final distance = direction.distance;

      if (active && distance > 1) {
        final unit = direction / distance;
        _arrow(canvas, pos + unit * nodeRadius, center - unit * 100, color.withAlpha(230));
      }

      _glow(canvas, pos, nodeRadius * .75, color);
      canvas.drawCircle(pos, nodeRadius, Paint()..color = color.withAlpha(active ? 62 : 22));
      canvas.drawCircle(
        pos,
        nodeRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 3.2 : 1.5
          ..color = color.withAlpha(active ? 250 : 110),
      );

      final emoji = _clean(node['emoji']?.toString() ?? '');
      if (emoji.isNotEmpty) {
        _text(canvas, emoji, pos.translate(0, -29), const TextStyle(fontSize: 31), maxWidth: nodeRadius * 1.6, maxLines: 1);
      }

      _text(
        canvas,
        _label(node),
        pos.translate(0, 7),
        TextStyle(color: active ? Colors.white : const Color(0xFFD2D6E8), fontSize: 13.5, fontWeight: FontWeight.w900, height: 1.15),
        maxWidth: nodeRadius * 1.7,
        maxLines: 2,
      );

      if (value.isNotEmpty || caption.isNotEmpty) {
        _text(
          canvas,
          value.isNotEmpty ? value : caption,
          pos.translate(0, 35),
          TextStyle(color: color.withAlpha(active ? 250 : 170), fontSize: 10.5, fontWeight: FontWeight.w800),
          maxWidth: nodeRadius * 1.7,
          maxLines: 1,
        );
      }
    }

    final centerWidth = math.min(360.0, math.max(250.0, size.width * .27));
    final centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: centerWidth, height: 128),
      const Radius.circular(32),
    );

    canvas.drawRRect(
      centerRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6257D8), Color(0xFF9B70F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(centerRect.outerRect),
    );
    canvas.drawRRect(centerRect, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFECE9FF));

    _text(canvas, topic, center.translate(0, -20), const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900), maxWidth: centerWidth - 30, maxLines: 2);
    _text(canvas, 'CORE IDEA', center.translate(0, 23), const TextStyle(color: Color(0xFFECE9FF), fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: 1.2), maxWidth: centerWidth - 30, maxLines: 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Small decorative sparkles make the lesson feel more like a visual
    // teaching board and less like a collection of UI cards.
    _star(canvas, Offset(size.width * .07, size.height * .16), 6, _palette[0]);
    _star(canvas, Offset(size.width * .92, size.height * .22), 5, _palette[3]);
    _star(canvas, Offset(size.width * .08, size.height * .82), 4, _palette[2]);
    _star(canvas, Offset(size.width * .94, size.height * .78), 6, _palette[1]);

    final type = visualType.isNotEmpty
        ? visualType
        : topic.toLowerCase().contains('pointer')
            ? 'pointer'
            : 'concept';

    if (type.contains('pointer')) {
      _drawPointer(canvas, size);
    } else {
      _drawGeneric(canvas, size);
    }

  }

  @override
  bool shouldRepaint(covariant _FunVisualLessonPainter oldDelegate) {
    return oldDelegate.activeStage != activeStage ||
        oldDelegate.reveal != reveal ||
        oldDelegate.nodes != nodes ||
        oldDelegate.visualType != visualType ||
        oldDelegate.topic != topic;
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

class _InteractiveAILesson extends StatelessWidget {
  final String topic;
  final String centralIdea;
  final List<Map<String, String>> steps;
  final Map<String, dynamic> data;
  final int activeStage;
  final bool isVoicePlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Future<void> Function() onPlayPause;

  const _InteractiveAILesson({
    required this.topic,
    required this.centralIdea,
    required this.steps,
    required this.data,
    required this.activeStage,
    required this.isVoicePlaying,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
  });

  bool get _isPointer => topic.toLowerCase().contains('pointer') ||
      data['visual_type']?.toString().toLowerCase().contains('pointer') == true;

  int get _stageCount => _isPointer ? 5 : math.max(1, math.min(5, steps.length)).toInt();

  String _stageExplanation() {
    if (_isPointer) {
      const pointerText = [
        'A variable stores a value in memory.',
        'Every variable is stored at a specific memory address.',
        'A pointer is a special variable used to store an address.',
        'Here, p stores the address 1000.',
        'Using *p lets us access the value stored at that address.',
      ];
      return pointerText[activeStage.clamp(0, 4)];
    }

    if (steps.isNotEmpty) {
      final index = activeStage.clamp(0, steps.length - 1);
      final title = steps[index]['title'] ?? '';
      final description = steps[index]['description'] ?? '';
      return [title, description]
          .where((value) => value.trim().isNotEmpty)
          .join('. ');
    }
    return centralIdea;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = _lessonAccent(activeStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LessonBoard(
          topic: topic,
          activeStage: activeStage,
          isPointer: _isPointer,
          steps: steps,
          explanation: _stageExplanation(),
          centralIdea: centralIdea,
          data: data,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LessonNavButton(
                icon: Icons.arrow_back_rounded,
                label: 'Previous',
                enabled: onPrevious != null,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 12),
            _LessonPlayButton(
              isPlaying: isVoicePlaying,
              accent: accent,
              onPressed: () => onPlayPause(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LessonNavButton(
                icon: Icons.arrow_forward_rounded,
                label: 'Next',
                iconOnRight: true,
                enabled: onNext != null,
                onPressed: onNext,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Center(
          child: Text(
            'Step ${activeStage + 1} / $_stageCount',
            style: TextStyle(
              color: dark ? const Color(0xFFD7D9EA) : const Color(0xFF4E5270),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

Color _lessonAccent(int stage) {
  const colors = [
    Color(0xFF45D7E8),
    Color(0xFFFFC857),
    Color(0xFFFF7AA2),
    Color(0xFF9B7BFF),
    Color(0xFF63E6BE),
  ];
  return colors[stage.clamp(0, colors.length - 1)];
}

class _LessonBoard extends StatelessWidget {
  final String topic;
  final int activeStage;
  final bool isPointer;
  final List<Map<String, String>> steps;
  final String explanation;
  final String centralIdea;
  final Map<String, dynamic> data;

  const _LessonBoard({
    required this.topic,
    required this.activeStage,
    required this.isPointer,
    required this.steps,
    required this.explanation,
    required this.centralIdea,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardHeight = math.max(
          500.0,
          math.min(680.0, constraints.maxWidth * .52),
        );
        return Container(
          width: double.infinity,
          height: boardHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1731), Color(0xFF121F43), Color(0xFF1A2350)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF263C68), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        topic,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'AI teacher • watch the idea happen',
                  style: TextStyle(
                    color: Colors.white.withAlpha(170),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<int>(activeStage),
                      child: isPointer
                          ? _PointerTeachingScene(stage: activeStage)
                          : _DynamicTeachingScene(
                              topic: topic,
                              stage: activeStage,
                              steps: steps,
                              centralIdea: centralIdea,
                              data: data,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _TeacherSpeechBubble(
                  text: explanation,
                  accent: _lessonAccent(activeStage),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PointerTeachingScene extends StatelessWidget {
  final int stage;

  const _PointerTeachingScene({required this.stage});

  double _opacityFor(int itemStage) {
    if (itemStage > stage) return 0.0;
    if (itemStage == stage) return 1.0;
    return 0.52;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final variableWidth = compact ? math.min(240.0, constraints.maxWidth * .72) : 230.0;
        final memoryWidth = compact ? math.min(220.0, constraints.maxWidth * .66) : 210.0;
        final arrowLabel = stage >= 3 ? 'stores address' : 'memory';

        if (compact) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: _opacityFor(0),
                  child: _TeachingVariable(
                    width: variableWidth,
                    active: stage == 0,
                  ),
                ),
                if (stage >= 1) ...[
                  const SizedBox(height: 8),
                  Icon(Icons.arrow_downward_rounded, color: _lessonAccent(1), size: 32),
                  Text(
                    'stored in memory',
                    style: TextStyle(color: _lessonAccent(1), fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _opacityFor(1),
                    child: _MemoryBlock(width: memoryWidth, active: stage == 1 || stage >= 3),
                  ),
                ],
                if (stage >= 2) ...[
                  const SizedBox(height: 12),
                  Icon(Icons.arrow_downward_rounded, color: _lessonAccent(3), size: 32),
                  const SizedBox(height: 6),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _opacityFor(2),
                    child: _PointerBubble(active: stage == 2 || stage >= 3),
                  ),
                ],
                if (stage >= 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    stage == 4 ? '*p  →  10' : 'p  →  1000',
                    style: TextStyle(
                      color: _lessonAccent(stage),
                      fontSize: stage == 4 ? 30 : 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PointerArrowPainter(stage: stage),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              left: compact ? 18 : constraints.maxWidth * .09,
              top: constraints.maxHeight * .19,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _opacityFor(0),
                child: _TeachingVariable(
                  width: variableWidth,
                  active: stage == 0,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              right: compact ? 18 : constraints.maxWidth * .09,
              top: constraints.maxHeight * .19,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _opacityFor(1),
                child: _MemoryBlock(
                  width: memoryWidth,
                  active: stage == 1 || stage >= 3,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              right: compact ? 28 : constraints.maxWidth * .12,
              top: constraints.maxHeight * .62,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _opacityFor(2),
                child: _PointerBubble(active: stage == 2 || stage >= 3),
              ),
            ),
            if (stage >= 3)
              Positioned(
                left: 0,
                right: 0,
                top: constraints.maxHeight * .49,
                child: Center(
                  child: AnimatedScale(
                    scale: stage == 3 ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      arrowLabel,
                      style: TextStyle(
                        color: _lessonAccent(stage),
                        fontSize: compact ? 14 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            if (stage == 4)
              Positioned(
                left: 0,
                right: 0,
                top: constraints.maxHeight * .71,
                child: Center(
                  child: AnimatedScale(
                    scale: 1.08,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '*p  →  10',
                      style: TextStyle(
                        color: _lessonAccent(4),
                        fontSize: compact ? 28 : 38,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(color: Color(0x8863E6BE), blurRadius: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              top: 20,
              child: _Sparkle(color: _lessonAccent(0), size: 10),
            ),
            Positioned(
              right: 24,
              top: 36,
              child: _Sparkle(color: _lessonAccent(3), size: 8),
            ),
            Positioned(
              left: constraints.maxWidth * .45,
              bottom: 12,
              child: _Sparkle(color: _lessonAccent(1), size: 7),
            ),
          ],
        );
      },
    );
  }
}

class _TeachingVariable extends StatelessWidget {
  final double width;
  final bool active;

  const _TeachingVariable({required this.width, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Variable',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFB8C1D8),
            fontSize: width < 190 ? 17 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'x = 10',
          style: TextStyle(
            color: _lessonAccent(0),
            fontSize: width < 190 ? 18 : 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: width,
          height: width < 190 ? 72 : 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF132B35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _lessonAccent(0),
              width: active ? 3 : 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _lessonAccent(0).withAlpha(100),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            '1000',
            style: TextStyle(
              color: Colors.white,
              fontSize: width < 190 ? 25 : 31,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'memory address',
          style: TextStyle(
            color: Colors.white.withAlpha(active ? 220 : 130),
            fontSize: width < 190 ? 12 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MemoryBlock extends StatelessWidget {
  final double width;
  final bool active;

  const _MemoryBlock({required this.width, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Memory',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFB8C1D8),
            fontSize: width < 180 ? 17 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Address 1000',
          style: TextStyle(
            color: _lessonAccent(1),
            fontSize: width < 180 ? 16 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: width,
          height: width < 180 ? 72 : 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF302A18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _lessonAccent(1),
              width: active ? 3 : 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _lessonAccent(1).withAlpha(90),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Text(
            '10',
            style: TextStyle(
              color: Colors.white,
              fontSize: width < 180 ? 26 : 31,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'value stored here',
          style: TextStyle(
            color: Colors.white.withAlpha(active ? 220 : 130),
            fontSize: width < 180 ? 12 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PointerBubble extends StatelessWidget {
  final bool active;

  const _PointerBubble({required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pointer',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFB8C1D8),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'p',
          style: TextStyle(
            color: _lessonAccent(3),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 108,
          height: 108,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF251C3A),
            border: Border.all(
              color: _lessonAccent(3),
              width: active ? 3 : 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _lessonAccent(3).withAlpha(105),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: const Text(
            'p',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'stores an address',
          style: TextStyle(
            color: Colors.white.withAlpha(active ? 220 : 130),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PointerArrowPainter extends CustomPainter {
  final int stage;

  _PointerArrowPainter({required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final compact = size.width < 620;
    final leftX = compact ? 18.0 : size.width * .09;
    final rightX = compact ? 18.0 : size.width * .09;
    final variableWidth = compact ? 170.0 : 230.0;
    final memoryWidth = compact ? 150.0 : 210.0;
    final y = size.height * .37;
    final start = Offset(leftX + variableWidth, y);
    final end = Offset(size.width - rightX - memoryWidth, y);

    if (stage >= 1) {
      _drawArrow(canvas, start, end, _lessonAccent(1), 'address');
    }

    if (stage >= 3) {
      final p = Offset(size.width - rightX - 55, size.height * .62);
      final memory = Offset(size.width - rightX - memoryWidth / 2, size.height * .37 + 40);
      _drawArrow(canvas, p, memory, _lessonAccent(3), 'p → 1000');
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, String label) {
    final paint = Paint()
      ..color = color.withAlpha(220)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(start.dx, start.dy);
    final midX = (start.dx + end.dx) / 2;
    path.cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    final direction = (end - start);
    final distance = direction.distance;
    if (distance > 1) {
      final unit = direction / distance;
      final side = Offset(-unit.dy, unit.dx);
      final tip = end;
      final p1 = tip - unit * 16 + side * 8;
      final p2 = tip - unit * 16 - side * 8;
      final arrow = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(arrow, Paint()..color = color);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 130);
    tp.paint(canvas, Offset((start.dx + end.dx) / 2 - tp.width / 2, start.dy - 28));
  }

  @override
  bool shouldRepaint(covariant _PointerArrowPainter oldDelegate) => oldDelegate.stage != stage;
}

class _DynamicTeachingScene extends StatelessWidget {
  final String topic;
  final int stage;
  final List<Map<String, String>> steps;
  final String centralIdea;
  final Map<String, dynamic> data;

  const _DynamicTeachingScene({
    required this.topic,
    required this.stage,
    required this.steps,
    required this.centralIdea,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final count = math.max(1, math.min(5, steps.length));
    final labels = steps.isEmpty
        ? [topic]
        : steps.take(count).map((step) {
            final title = step['title'] ?? 'Step';
            return title.isEmpty ? topic : title;
          }).toList();

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 760;
          final visible = math.min(stage + 1, labels.length);
          return SingleChildScrollView(
            child: Flex(
              direction: horizontal ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < visible; i++) ...[
                  _ConceptBubble(
                    label: labels[i],
                    number: i + 1,
                    accent: _lessonAccent(i),
                    active: i == stage,
                  ),
                  if (i != visible - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontal ? 10 : 0,
                        vertical: horizontal ? 0 : 9,
                      ),
                      child: Icon(
                        horizontal
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_downward_rounded,
                        color: _lessonAccent(i),
                        size: 30,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConceptBubble extends StatelessWidget {
  final String label;
  final int number;
  final Color accent;
  final bool active;

  const _ConceptBubble({
    required this.label,
    required this.number,
    required this.accent,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: accent.withAlpha(active ? 45 : 22),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withAlpha(active ? 255 : 120), width: active ? 3 : 1.5),
        boxShadow: active
            ? [BoxShadow(color: accent.withAlpha(90), blurRadius: 24, spreadRadius: 2)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$number',
            style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFD5D9E8),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherSpeechBubble extends StatelessWidget {
  final String text;
  final Color accent;

  const _TeacherSpeechBubble({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
            boxShadow: [
              BoxShadow(color: accent.withAlpha(75), blurRadius: 16),
            ],
          ),
          child: const Text('✨', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111C38),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(left: BorderSide(color: accent, width: 4)),
            ),
            child: Text(
              text,
              softWrap: true,
              style: const TextStyle(
                color: Color(0xFFF4F6FF),
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool iconOnRight;
  final VoidCallback? onPressed;

  const _LessonNavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Icon(icon, size: 20),
      const SizedBox(width: 7),
      Text(label),
    ];
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled ? Colors.white : const Color(0xFF747A91),
        backgroundColor: const Color(0xFF151E3A),
        side: BorderSide(color: enabled ? const Color(0xFF42527A) : const Color(0xFF28314E)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconOnRight ? children.reversed.toList() : children,
      ),
    );
  }
}

class _LessonPlayButton extends StatelessWidget {
  final bool isPlaying;
  final Color accent;
  final VoidCallback onPressed;

  const _LessonPlayButton({
    required this.isPlaying,
    required this.accent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? 'Pause teacher voice' : 'Play teacher voice',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(isPlaying ? 120 : 70),
                blurRadius: isPlaying ? 24 : 14,
                spreadRadius: isPlaying ? 2 : 0,
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _Sparkle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome, color: color.withAlpha(190), size: size * 2);
  }
}

