import 'package:flutter/material.dart';

import '../module2/data/syllabus_data.dart';
import '../module2/screens/graph_screen.dart';

class SubjectScreen extends StatelessWidget {
  final String subject;

  const SubjectScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    // Map Module 1 subject names to Module 2 syllabus names.
    String module2Subject = subject;

    if (subject == 'Operating System') {
      module2Subject = 'Operating Systems';
    } else if (subject == 'OOP Java') {
      module2Subject = 'OOPs – Java';
    }

    final subjectTopics = syllabusTopics
        .where(
          (topic) => topic.subject == module2Subject,
        )
        .toList();

    if (subjectTopics.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(subject),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'No topics found for this subject.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GraphScreen(
      subject: module2Subject,
      topics: subjectTopics,
    );
  }
}