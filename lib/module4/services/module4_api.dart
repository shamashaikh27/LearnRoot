import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/topic.dart';
import '../models/quiz_question.dart';
import '../models/learning_resource.dart';

class Module4Api {
  // Android emulator:
  // http://10.0.2.2:5000
  //
  // Physical phone:
  // use your computer's LAN IP, for example:
  // http://192.168.1.5:5000
  //
  // Windows desktop:
  // http://127.0.0.1:5000
  static const String baseUrl = 'http://127.0.0.1:5000';

  // =============================================================
  // EXISTING MODULE 4 METHODS
  // =============================================================

  static Future<List<Module4Topic>> getTopics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/topics'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Module4Topic.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<List<QuizQuestion>> getQuiz(int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/$topicId'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! Map || data['questions'] is! List) {
      return [];
    }

    final raw = data['questions'] as List;

    return raw
        .whereType<Map>()
        .map(
          (item) => QuizQuestion.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> submitQuiz({
    required int topicId,
    required Map<int, String> answers,
  }) async {
    final converted = <String, String>{};

    answers.forEach((key, value) {
      converted['$key'] = value;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/submit-quiz'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic_id': topicId,
        'answers': converted,
      }),
    );

    _check(response);

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // =============================================================
  // CURRENT AI NOTES METHOD
  // =============================================================

  static Future<String> getAiNotesByTopicName(
    String topicName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topicName,
      }),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! Map) {
      throw Exception('Invalid AI notes response.');
    }

    return '${data['notes'] ?? ''}';
  }

  // =============================================================
  // OLD DATABASE-BASED NOTES METHOD
  // Kept so existing code does not break.
  // =============================================================

  static Future<String> getAiNotes(int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai-notes/$topicId'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! Map || data['status'] != 'success') {
      throw Exception(
        data is Map
            ? '${data['message'] ?? 'Unable to load AI notes.'}'
            : 'Unable to load AI notes.',
      );
    }

    return '${data['notes'] ?? ''}';
  }

  // =============================================================
  // CURRENT AI QUIZ
  // POST /quiz
  // =============================================================

  static Future<List<QuizQuestion>> getAiQuiz(
    String topicName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topicName,
      }),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! Map || data['questions'] is! List) {
      throw Exception(
        'No quiz questions were returned.',
      );
    }

    final rawQuestions = data['questions'] as List;

    final questions = rawQuestions
        .whereType<Map>()
        .map(
          (item) => QuizQuestion.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    if (questions.isEmpty) {
      throw Exception(
        'No valid quiz questions were returned.',
      );
    }

    return questions;
  }

  // =============================================================
  // CURRENT AI QUIZ SUBMISSION
  // POST /recommendation
  // =============================================================

  static Future<Map<String, dynamic>> submitAiQuiz({
    required String topicName,
    required List<QuizQuestion> questions,
    required Map<int, String> answers,
  }) async {
    int score = 0;

    final solutions = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      final selected =
          (answers[i] ?? '').trim().toUpperCase();

      final correct =
          question.correctAnswer.trim().toUpperCase();

      if (selected == correct) {
        score++;
      }

      solutions.add({
        'question': question.question,
        'selected_answer': selected,
        'correct_answer': correct,
        'solution': question.solution ?? '',
      });
    }

    final percentage = questions.isEmpty
        ? 0.0
        : (score / questions.length) * 100;

    // Send the score to the existing AI recommendation endpoint.
    final response = await http.post(
      Uri.parse('$baseUrl/recommendation'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topicName,
        'score': percentage,
      }),
    );

    _check(response);

    final recommendationResponse = jsonDecode(
      response.body,
    );

    if (recommendationResponse is! Map) {
      throw Exception(
        'Invalid recommendation response.',
      );
    }

    final recommendation =
        Map<String, dynamic>.from(
      recommendationResponse,
    );

    // Add quiz result information expected by
    // QuizResultScreen.
    return {
      ...recommendation,
      'score': score,
      'total_questions': questions.length,
      'percentage': percentage,
      'solutions': solutions,
    };
  }

  // =============================================================
  // EXISTING VIDEO METHOD
  // =============================================================

  static Future<List<LearningResource>> getVideos(
    int topicId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/$topicId'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! Map || data['resources'] is! List) {
      return [];
    }

    final raw = data['resources'] as List;

    return raw
        .whereType<Map>()
        .map(
          (item) => LearningResource.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (resource) => resource.isVideo,
        )
        .toList();
  }

  // =============================================================
  // EXISTING WEAK TOPICS METHOD
  // =============================================================

  static Future<List<Map<String, dynamic>>>
      getWeakTopics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/weak-topics'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // =============================================================
  // EXISTING ANALYTICS METHOD
  // =============================================================

  static Future<Map<String, dynamic>?> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
    );

    _check(response);

    final data = jsonDecode(response.body);

    if (data is Map &&
        data['status'] == 'success') {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  // =============================================================
  // COMMON RESPONSE CHECK
  // =============================================================

  static void _check(http.Response response) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Server error ${response.statusCode}: '
        '${response.body}',
      );
    }
  }
}