import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../models/quiz_question.dart';
import '../services/module4_api.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Module4Topic topic;

  const QuizScreen({
    super.key,
    required this.topic,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool loading = true;
  bool submitting = false;
  String? error;

  List<QuizQuestion> questions = [];
  final Map<int, String> answers = {};

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    try {
      final data = await Module4Api.getQuiz(widget.topic.topicId);
      if (!mounted) return;

      setState(() {
        questions = data;
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

  Future<void> submitQuiz() async {
    if (answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions.'),
        ),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      final result = await Module4Api.submitQuiz(
        topicId: widget.topic.topicId,
        answers: answers,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            topic: widget.topic,
            questions: questions,
            answers: answers,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => submitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.topicName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    _quizHeader(context),
                    const SizedBox(height: 16),
                    if (questions.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No questions found for this topic.'),
                        ),
                      ),
                    ...questions.asMap().entries.map(
                      (entry) => _questionCard(
                        context,
                        entry.key,
                        entry.value,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: submitting ? null : submitQuiz,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        submitting ? 'Submitting...' : 'Submit Quiz',
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _quizHeader(BuildContext context) {
    return Container(
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

  Widget _questionCard(
    BuildContext context,
    int index,
    QuizQuestion question,
  ) {
    final options = ['A', 'B', 'C', 'D'];

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${index + 1}. ${question.question}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (question.difficulty != null) ...[
              const SizedBox(height: 9),
              Chip(
                label: Text(question.difficulty!),
              ),
            ],
            const SizedBox(height: 8),
            ...options.map(
              (option) => RadioListTile<String>(
                value: option,
                groupValue: answers[question.quizId],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    answers[question.quizId] = value;
                  });
                },
                title: Text(
                  '$option. ${question.optionText(option)}',
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
