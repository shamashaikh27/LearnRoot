import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Saves per-user learning activity used by the LearnRoot Progress page.
class ProgressService {
  ProgressService._();

  static Future<void> saveQuizAttempt({
    required String subject,
    required String topicName,
    required int correctAnswers,
    required int totalQuestions,
    required double percentage,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quizAttempts')
        .add({
      'subject': subject.trim(),
      'topicName': topicName.trim(),
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> markTopicCompleted({
    required String subject,
    required String topicId,
    required String topicName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('topicProgress')
        .doc(topicId)
        .set({
      'topicId': topicId,
      'topicName': topicName.trim(),
      'subject': subject.trim(),
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
