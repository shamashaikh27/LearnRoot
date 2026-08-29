import 'package:flutter/material.dart';

import '../data/syllabus_data.dart';

class TopicDetailsScreen extends StatelessWidget {
  final Topic selectedTopic;

  const TopicDetailsScreen({
    super.key,
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    final prerequisites = syllabusTopics.where(
      (topic) => selectedTopic.prerequisites.contains(topic.id),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTopic.name),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // -----------------------------------------------
            // TOPIC TITLE
            // -----------------------------------------------

            Center(
              child: Text(
                selectedTopic.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------------------------
            // AI EXPLANATION SECTION
            // -----------------------------------------------

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 28,
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          'AI Explanation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'AI-generated summarized explanation '
                      'with examples and visual explanations '
                      'will appear here.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'AI explanation will be connected later.',
                              ),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.play_circle_outline,
                        ),

                        label: const Text(
                          'Start AI Explanation',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------------------------------
            // PREREQUISITES
            // -----------------------------------------------

            const Text(
              'Prerequisites',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (prerequisites.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This topic has no prerequisites.',
                  ),
                ),
              )
            else
              ...prerequisites.map(
                (topic) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_tree,
                    ),
                    title: Text(topic.name),
                  ),
                ),
              ),

            const SizedBox(height: 25),

            // -----------------------------------------------
            // EXPLORE FURTHER
            // -----------------------------------------------

            const Text(
              'Explore Further',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // Notes
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.description,
                  size: 30,
                ),
                title: const Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Read detailed notes about this topic',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'AI-generated notes will be connected later.',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // YouTube
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.play_circle,
                  size: 30,
                ),
                title: const Text(
                  'YouTube Recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Watch recommended videos about this topic',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'YouTube recommendations will be connected later.',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}