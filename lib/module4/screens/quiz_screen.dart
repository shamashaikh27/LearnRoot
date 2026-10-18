import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/progress_service.dart';
import '../models/topic.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  final Module4Topic topic;

  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const String backendUrl = 'http://127.0.0.1:5000';

  bool loading = true;
  bool submitting = false;
  bool submitted = false;

  String? error;

  List<QuizQuestion> questions = [];

  final Map<int, String> answers = {};

  int score = 0;

  Map<String, dynamic>? recommendation;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  // ============================================================
  // LOAD AI QUIZ
  // ============================================================

  Future<void> loadQuiz() async {
    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/quiz'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'topic': widget.topic.topicName}),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          decoded is Map && decoded['error'] != null
              ? decoded['error'].toString()
              : 'Quiz generation failed.',
        );
      }

      final rawQuestions = decoded is Map ? decoded['questions'] : null;

      if (rawQuestions is! List || rawQuestions.isEmpty) {
        throw Exception('No quiz questions were returned.');
      }

      final loadedQuestions = rawQuestions
          .whereType<Map>()
          .map((item) => QuizQuestion.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      if (loadedQuestions.isEmpty) {
        throw Exception('No valid quiz questions were returned.');
      }

      if (!mounted) return;

      setState(() {
        questions = loadedQuestions;
        answers.clear();
        score = 0;
        submitted = false;
        submitting = false;
        recommendation = null;
        error = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // SUBMIT QUIZ
  // ============================================================

  Future<void> submitQuiz() async {
    if (questions.isEmpty) {
      return;
    }

    // Make sure every question is answered.
    if (answers.length < questions.length) {
      final remaining = questions.length - answers.length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remaining == 1
                ? 'Please answer the remaining question.'
                : 'Please answer all questions. '
                      '$remaining remaining.',
          ),
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // CALCULATE SCORE
    // ------------------------------------------------------------

    int calculatedScore = 0;

    for (int i = 0; i < questions.length; i++) {
      final selected = (answers[i] ?? '').trim().toUpperCase();

      final correct = questions[i].correctAnswer.trim().toUpperCase();

      if (selected == correct) {
        calculatedScore++;
      }
    }

    final percentage = questions.isEmpty
        ? 0.0
        : (calculatedScore / questions.length) * 100;

    if (!mounted) return;

    // Show result state while AI recommendation loads.
    setState(() {
      score = calculatedScore;
      submitted = true;
      submitting = true;
      recommendation = null;
      error = null;
    });

    try {
      await ProgressService.saveQuizAttempt(
        subject: widget.topic.subject,
        topicName: widget.topic.topicName,
        correctAnswers: calculatedScore,
        totalQuestions: questions.length,
        percentage: percentage,
      );

      // Mark the topic as completed if the score is at least 60%.
      if (percentage >= 60) {
        await ProgressService.markTopicCompleted(
          subject: widget.topic.subject,
          topicId: widget.topic.topicCode.toString(),
          topicName: widget.topic.topicName,
        );
      }
    } catch (e) {
      debugPrint('Could not save quiz progress: $e');
    }

    // ------------------------------------------------------------
    // AI PERSONALIZED RECOMMENDATION
    // ------------------------------------------------------------

    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/recommendation'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': widget.topic.topicName,
              'score': percentage,
            }),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          decoded is Map && decoded['error'] != null
              ? decoded['error'].toString()
              : 'Recommendation generation failed.',
        );
      }

      if (decoded is! Map) {
        throw Exception('Invalid recommendation response.');
      }

      if (!mounted) return;

      setState(() {
        recommendation = Map<String, dynamic>.from(decoded);

        submitting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        submitting = false;

        error =
            'Quiz submitted, but AI recommendation '
            'could not be loaded.\n\n'
            '${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  // ============================================================
  // TRY ANOTHER QUIZ
  // ============================================================

  Future<void> tryAnotherQuiz() async {
    setState(() {
      loading = true;
      submitting = false;
      submitted = false;
      questions = [];
      answers.clear();
      score = 0;
      recommendation = null;
      error = null;
    });

    await loadQuiz();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.topicName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null && questions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(error!, textAlign: TextAlign.center),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 1120
                    ? 1050.0
                    : constraints.maxWidth;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ------------------------------------------------
                            // QUIZ HEADER
                            // ------------------------------------------------

                            _buildHeader(context),

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // ERROR AFTER SUBMISSION
                            // ------------------------------------------------
                            if (error != null && submitted) ...[
                              _buildError(context),
                              const SizedBox(height: 16),
                            ],

                            // ------------------------------------------------
                            // QUIZ RESULT
                            // ------------------------------------------------
                            if (submitted && !submitting) ...[
                              _buildResult(context),

                              const SizedBox(height: 28),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.fact_check_rounded,
                                    color: Color(0xFF7B61D1),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Quiz Review',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Review your answers and understand the correct solutions below.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.60),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),

                              const SizedBox(height: 18),
                            ],

                            // ------------------------------------------------
                            // AI RECOMMENDATION LOADING
                            // ------------------------------------------------
                            if (submitting)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 12),
                                    Text(
                                      'Generating your personalized recommendation...',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                            // ------------------------------------------------
                            // QUESTIONS
                            // ------------------------------------------------
                            ...questions.asMap().entries.map(
                              (entry) => _buildQuestion(
                                context,
                                entry.key,
                                entry.value,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ------------------------------------------------
                            // SUBMIT / TRY AGAIN
                            // ------------------------------------------------
                            if (!submitted)
                              _buildSubmitButton(context)
                            else if (!submitting) ...[
                              const SizedBox(height: 4),
                              _buildTryAgainButton(context),
                            ],
                          ],
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
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593AB9), Color(0xFF7B61D1)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.topic.subject,
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 6),

          Text(
            widget.topic.topicName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${questions.length} questions • Easy + Moderate + Hard',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION
  // ============================================================

  Widget _buildQuestion(
    BuildContext context,
    int index,
    QuizQuestion question,
  ) {
    final selected = answers[index];

    final correct = question.correctAnswer.trim().toUpperCase();

    const options = ['A', 'B', 'C', 'D'];

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // QUESTION NUMBER
            // ----------------------------------------------------

            Text(
              'Question ${index + 1}',
              style: const TextStyle(
                color: Color(0xFF7B61D1),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            // ----------------------------------------------------
            // QUESTION TEXT
            // ----------------------------------------------------
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, height: 1.4),
            ),

            // ----------------------------------------------------
            // DIFFICULTY
            // ----------------------------------------------------
            if (question.difficulty != null) ...[
              const SizedBox(height: 9),
              Chip(label: Text(question.difficulty!)),
            ],

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // OPTIONS
            // ----------------------------------------------------
            ...options.map((option) {
              final isSelected = selected == option;

              final isCorrect = submitted && correct == option;

              final isWrong = submitted && isSelected && correct != option;

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: submitted
                      ? null
                      : () {
                          setState(() {
                            answers[index] = option;
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.10)
                          : isWrong
                          ? Colors.red.withValues(alpha: 0.10)
                          : isSelected
                          ? const Color(0xFF7B61D1).withValues(alpha: 0.10)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green
                            : isWrong
                            ? Colors.red
                            : isSelected
                            ? const Color(0xFF7B61D1)
                            : Theme.of(context).dividerColor,
                        width: (isSelected || isCorrect || isWrong) ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --------------------------------------
                        // OPTION LETTER
                        // --------------------------------------

                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCorrect
                                ? Colors.green
                                : isWrong
                                ? Colors.red
                                : isSelected
                                ? const Color(0xFF7B61D1)
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: isCorrect
                                  ? Colors.green
                                  : isWrong
                                  ? Colors.red
                                  : isSelected
                                  ? const Color(0xFF7B61D1)
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: (isSelected || isCorrect || isWrong)
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // --------------------------------------
                        // OPTION TEXT
                        // --------------------------------------
                        Expanded(
                          child: Text(
                            question.optionText(option),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // ----------------------------------------------------
            // ANSWER + SOLUTION AFTER SUBMISSION
            // ----------------------------------------------------
            if (submitted) ...[
              const SizedBox(height: 4),

              Text(
                'Correct answer: $correct',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              if (question.solution != null &&
                  question.solution!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),

                Text(
                  question.solution!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.70),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: submitting ? null : submitQuiz,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Submit Quiz'),
      ),
    );
  }

  // ============================================================
  // TRY AGAIN BUTTON
  // ============================================================

  Widget _buildTryAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: tryAnotherQuiz,
        child: const Text('Try Another Quiz'),
      ),
    );
  }

  // ============================================================
  // RESULT
  // ============================================================

  Widget _buildResult(BuildContext context) {
    final total = questions.length;

    final percentage = total == 0 ? 0.0 : (score / total) * 100;

    final correctCount = score;
    final wrongCount = total - score;

    final level = recommendation?['level']?.toString().trim().isNotEmpty == true
        ? recommendation!['level'].toString()
        : _fallbackLevel(percentage);

    final summary =
        recommendation?['summary']?.toString().trim().isNotEmpty == true
        ? recommendation!['summary'].toString()
        : 'Your quiz has been evaluated successfully.';

    final studyNext = recommendation?['study_next'];

    final progress = (percentage / 100).clamp(0.0, 1.0);

    String performanceMessage;
    IconData performanceIcon;

    if (percentage >= 80) {
      performanceMessage =
          'Excellent work! You have a strong understanding of this topic.';
      performanceIcon = Icons.emoji_events_rounded;
    } else if (percentage >= 60) {
      performanceMessage =
          'Good job! You are building a solid understanding. Keep going.';
      performanceIcon = Icons.thumb_up_alt_rounded;
    } else if (percentage >= 40) {
      performanceMessage =
          'You are on the right track. A little more practice will help.';
      performanceIcon = Icons.trending_up_rounded;
    } else {
      performanceMessage = 'Keep practicing. Revising the key concepts will strengthen your basics.';
      performanceIcon = Icons.menu_book_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // MAIN RESULT BANNER
        // ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF593AB9), Color(0xFF7560D6), Color(0xFF8E78E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF593AB9).withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;

              // --------------------------------------------------
              // SCORE CIRCLE
              // --------------------------------------------------

              final scoreCircle = SizedBox(
                width: 118,
                height: 118,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 118,
                      height: 118,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withValues(alpha: 0.17),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        Text(
                          '$score / $total correct',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              // --------------------------------------------------
              // LEFT CONTENT
              // --------------------------------------------------

              final leftContent = Column(
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: compact
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Icon(performanceIcon, color: Colors.white, size: 22),

                      const SizedBox(width: 8),

                      const Text(
                        'Quiz Completed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Text(
                    level,
                    textAlign: compact ? TextAlign.center : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    performanceMessage,
                    textAlign: compact ? TextAlign.center : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              );

              // --------------------------------------------------
              // COMPACT LAYOUT
              // --------------------------------------------------

              if (compact) {
                return Column(
                  children: [
                    leftContent,
                    const SizedBox(height: 17),
                    scoreCircle,
                  ],
                );
              }

              // --------------------------------------------------
              // WIDE LAYOUT
              // --------------------------------------------------

              return Row(
                children: [
                  Expanded(child: leftContent),

                  const SizedBox(width: 20),

                  scoreCircle,

                  const SizedBox(width: 24),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Performance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '$correctCount correct  •  $wrongCount incorrect',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // STAT CARDS
        // ========================================================
        Row(
          children: [
            Expanded(
              child: _resultStatCard(
                context,
                icon: Icons.check_circle_rounded,
                title: 'Correct',
                value: '$correctCount',
                iconColor: Colors.green,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _resultStatCard(
                context,
                icon: Icons.cancel_rounded,
                title: 'Incorrect',
                value: '$wrongCount',
                iconColor: Colors.redAccent,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _resultStatCard(
                context,
                icon: Icons.percent_rounded,
                title: 'Accuracy',
                value: '${percentage.toStringAsFixed(0)}%',
                iconColor: const Color(0xFF7B61D1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ========================================================
        // AI LEARNING INSIGHT
        // ========================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF593AB9), Color(0xFF8E78E6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Learning Insight',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Personalized feedback based on your performance',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.58),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B61D1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: Color(0xFF7B61D1),
                      size: 19,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: Color(0xFF7B61D1),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 11),

              Text(
                summary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.70),
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // YOUR LEARNING PATH
        // ========================================================
        if (studyNext != null) ...[
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Text(
                      'Your Learning Path',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                Text(
                  'Study Next',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                _buildStudyNext(studyNext),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // RESULT STAT CARD
  // ============================================================

  Widget _resultStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 1),

          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.58),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDY NEXT
  // ============================================================

  Widget _buildStudyNext(dynamic studyNext) {
    if (studyNext is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: studyNext.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${item.toString()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.70),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Text(
      studyNext.toString(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
        fontSize: 12,
        height: 1.45,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.30)),
      ),
      child: Text(
        error!,
        style: const TextStyle(color: Colors.red, fontSize: 12, height: 1.45),
      ),
    );
  }

  // ============================================================
  // FALLBACK LEVEL
  // ============================================================

  String _fallbackLevel(double percentage) {
    if (percentage >= 80) {
      return 'Strong Understanding';
    }

    if (percentage >= 60) {
      return 'Good Progress';
    }

    if (percentage >= 40) {
      return 'Needs Improvement';
    }

    return 'Needs More Practice';
  }
}
