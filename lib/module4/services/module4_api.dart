import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/topic.dart';
import '../models/quiz_question.dart';
import '../models/learning_resource.dart';

class Module4Api {
  // Android emulator: http://10.0.2.2:5000
  // Physical phone: use your computer's LAN IP, e.g. http://192.168.1.5:5000
  // Windows desktop: http://127.0.0.1:5000
 static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<List<Module4Topic>> getTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));
    _check(response);

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .map((item) => Module4Topic.fromJson(item))
        .toList();
  }

  static Future<List<QuizQuestion>> getQuiz(int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/$topicId'),
    );
    _check(response);

    final data = jsonDecode(response.body);
    final raw = data['questions'];

    if (raw is! List) return [];

    return raw
        .map((item) => QuizQuestion.fromJson(item))
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic_id': topicId,
        'answers': converted,
      }),
    );

    _check(response);
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static Future<String> getAiNotes(int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai-notes/$topicId'),
    );
    _check(response);

    final data = jsonDecode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Unable to load AI notes.');
    }

    return '${data['notes'] ?? ''}';
  }

  static Future<List<LearningResource>> getVideos(int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/$topicId'),
    );
    _check(response);

    final data = jsonDecode(response.body);
    final raw = data['resources'];

    if (raw is! List) return [];

    return raw
        .map((item) => LearningResource.fromJson(item))
        .where((resource) => resource.isVideo)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getWeakTopics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/weak-topics'),
    );
    _check(response);

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<Map<String, dynamic>?> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
    );
    _check(response);

    final data = jsonDecode(response.body);
    if (data is Map && data['status'] == 'success') {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Server error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
