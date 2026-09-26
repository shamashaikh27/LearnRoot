import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../models/quiz_question.dart';
import 'smart_notes_screen.dart';
import 'video_resources_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final Module4Topic topic;
  final List<QuizQuestion> questions;
  final Map<int, String> answers;
  final Map<String, dynamic> result;

  const QuizResultScreen({
    super.key,
    required this.topic,
    required this.questions,
    required this.answers,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        double.tryParse('${result['percentage'] ?? 0}') ?? 0;
    final score = result['score'] ?? 0;
    final total = result['total_questions'] ?? questions.length;
    final solutions = result['solutions'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _scoreCard(context, percentage, score, total),
          const SizedBox(height: 18),
          if (solutions is List && solutions.isNotEmpty)
            _reviewSection(context, solutions),
          const SizedBox(height: 18),
          _featureCard(
            context,
            icon: Icons.auto_awesome,
            title: 'Smart AI Notes',
            subtitle: 'Generate or load saved notes for this topic.',
            buttonText: 'Open Smart Notes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SmartNotesScreen(topic: topic),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _featureCard(
            context,
            icon: Icons.ondemand_video,
            title: 'Recommended Videos',
            subtitle: 'Watch topic-related videos from your resources.',
            buttonText: 'View Videos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoResourcesScreen(topic: topic),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Topics'),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(
    BuildContext context,
    double percentage,
    dynamic score,
    dynamic total,
  ) {
    String message;
    if (percentage < 50) {
      message = '📖 Keep practicing and use Smart Notes for revision.';
    } else if (percentage < 80) {
      message = '👍 Good job! Smart Notes can help you improve.';
    } else {
      message = '🌟 Excellent performance! Use Smart Notes for quick revision.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593AB9), Color(0xFF7B61D1)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            '🎉 Quiz Completed!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Score: $score / $total',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _reviewSection(
    BuildContext context,
    List<dynamic> rawSolutions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📝 Quiz Review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Review your answers and correct solutions.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...rawSolutions.asMap().entries.map((entry) {
          final solution =
              Map<String, dynamic>.from(entry.value as Map);
          final quizId =
              int.tryParse('${solution['quiz_id'] ?? 0}') ?? 0;

          final question = questions.cast<QuizQuestion?>().firstWhere(
                (q) => q?.quizId == quizId,
                orElse: () => null,
              );

          final studentAnswer =
              '${solution['student_answer'] ?? ''}';
          final correctAnswer =
              '${solution['correct_answer'] ?? ''}';
          final isCorrect = solution['is_correct'] == true ||
              solution['is_correct'] == 1 ||
              '${solution['is_correct']}' == '1';

          return Card(
            color: isCorrect
                ? Colors.green.withValues(alpha: .10)
                : Colors.red.withValues(alpha: .10),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${entry.key + 1}. ${solution['question'] ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Answer: ${question?.optionText(studentAnswer) ?? studentAnswer}',
                  ),
                  Text(
                    'Correct Answer: ${question?.optionText(correctAnswer) ?? correctAnswer}',
                  ),
                  if ('${solution['solution'] ?? ''}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        'Explanation: ${solution['solution']}',
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 38,
              color: const Color(0xFF593AB9),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text(subtitle),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: onPressed,
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
