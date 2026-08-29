import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import '../data/syllabus_data.dart';
import 'topic_details_screen.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredTopics = syllabusTopics.where((topic) {
      return topic.name.toLowerCase().contains(
            searchText.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Structures'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search topic...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // Topic list
          Expanded(
            child: filteredTopics.isEmpty
                ? const Center(
                    child: Text('No topic found'),
                  )
                : ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            topic.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrerequisiteGraphScreen(
                                  selectedTopic: topic,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// PREREQUISITE GRAPH SCREEN
// ---------------------------------------------------------

class PrerequisiteGraphScreen extends StatelessWidget {
  final Topic selectedTopic;

  const PrerequisiteGraphScreen({
    super.key,
    required this.selectedTopic,
  });

  @override
  Widget build(BuildContext context) {
    final graph = Graph();

    // Selected topic
    final selectedNode = Node.Id(selectedTopic.id);
    graph.addNode(selectedNode);

    // Add only direct prerequisites
    for (final prerequisiteId in selectedTopic.prerequisites) {
      final prerequisiteTopic = syllabusTopics.firstWhere(
        (topic) => topic.id == prerequisiteId,
      );

      final prerequisiteNode = Node.Id(prerequisiteTopic.id);

      graph.addNode(prerequisiteNode);

      graph.addEdge(
        prerequisiteNode,
        selectedNode,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTopic.name),
      ),

      body: Column(
        children: [
          // -------------------------------------------------
          // GRAPH
          // -------------------------------------------------

          Expanded(
            child: selectedTopic.prerequisites.isEmpty
                ? const Center(
                    child: Text(
                      'This topic has no prerequisites.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(150),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: GraphView(
                        graph: graph,

                        algorithm: SugiyamaAlgorithm(
                          SugiyamaConfiguration(),
                        ),

                        paint: Paint()
                          ..color = Colors.blue
                          ..strokeWidth = 2
                          ..style = PaintingStyle.stroke,

                        builder: (Node node) {
                          final topicId = node.key?.value as String;

                          final topic = syllabusTopics.firstWhere(
                            (topic) => topic.id == topicId,
                          );

                          final isSelectedTopic =
                              topic.id == selectedTopic.id;

                          return GestureDetector(
                            onTap: () {
                              // If the student clicks a prerequisite,
                              // open that prerequisite's own graph.

                              if (topic.id == selectedTopic.id) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PrerequisiteGraphScreen(
                                    selectedTopic: topic,
                                  ),
                                ),
                              );
                            },

                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 140,
                                maxWidth: 220,
                              ),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),

                              decoration: BoxDecoration(
                                color: isSelectedTopic
                                    ? Colors.blue
                                    : Colors.white,

                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),

                                borderRadius:
                                    BorderRadius.circular(12),

                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                    color: Colors.black12,
                                  ),
                                ],
                              ),

                              child: Text(
                                topic.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelectedTopic
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),

          // -------------------------------------------------
          // LEARN TOPIC BUTTON
          // -------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          TopicDetailsScreen(
                        selectedTopic: selectedTopic,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.menu_book,
                ),

                label: Text(
                  'Learn ${selectedTopic.name}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}