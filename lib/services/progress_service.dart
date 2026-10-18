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

    final cleanSubject = subject.trim();
    final cleanTopicName = topicName.trim();

    // Use a stable document ID based on the subject and topic name.
    final progressId =
        '${cleanSubject.toLowerCase()}_${cleanTopicName.toLowerCase()}'
            .replaceAll(RegExp(r'[/\\.#$\[\]]'), '_');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('topicProgress')
        .doc(progressId)
        .set({
          'topicId': topicId,
          'topicName': cleanTopicName,
          'subject': cleanSubject,
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  static Future<void> saveRecentActivity({
    required String subject,
    required String topicId,
    required String topicName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('learningActivity')
        .doc('recent')
        .set({
          'subject': subject.trim(),
          'topicId': topicId,
          'topicName': topicName.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
