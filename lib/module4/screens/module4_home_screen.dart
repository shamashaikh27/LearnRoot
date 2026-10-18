import 'package:flutter/material.dart';

import '../models/topic.dart';

import '../services/module4_api.dart';

import 'quiz_screen.dart';

class Module4HomeScreen extends StatefulWidget {

  const Module4HomeScreen({super.key});

  @override

  State<Module4HomeScreen> createState() => _Module4HomeScreenState();

}

class _Module4HomeScreenState extends State<Module4HomeScreen> {

  bool loading = true;

  String? error;

  List<Module4Topic> topics = [];

  List<Map<String, dynamic>> weakTopics = [];

  Map<String, dynamic>? analytics;

  @override

  void initState() {

    super.initState();

    loadData();

  }

  Future<void> loadData() async {

    setState(() {

      loading = true;

      error = null;

    });

    try {

      final results = await Future.wait([

        Module4Api.getTopics(),

        Module4Api.getWeakTopics(),

        Module4Api.getAnalytics(),

      ]);

      if (!mounted) return;

      setState(() {

        topics = results[0] as List<Module4Topic>;

        weakTopics = results[1] as List<Map<String, dynamic>>;

        analytics = results[2] as Map<String, dynamic>?;

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

  Map<String, List<Module4Topic>> get groupedTopics {

    final grouped = <String, List<Module4Topic>>{};

    for (final topic in topics) {

      grouped.putIfAbsent(topic.subject, () => []).add(topic);

    }

    return grouped;

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F5FC),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        title: const Row(

          children: [

            Icon(

              Icons.school_rounded,

              color: Color(0xFF593AB9),

            ),

            SizedBox(width: 10),

            Text(

              'LearnRoot',

              style: TextStyle(

                fontWeight: FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

      body: loading

          ? const Center(

              child: CircularProgressIndicator(

                color: Color(0xFF593AB9),

              ),

            )

          : RefreshIndicator(

              color: const Color(0xFF593AB9),

              onRefresh: loadData,

              child: ListView(

                padding: const EdgeInsets.all(18),

                children: [

                  _heroCard(),

                  if (error != null) ...[

                    const SizedBox(height: 16),

                    _messageCard(error!),

                  ],

                  if (analytics != null) ...[

                    const SizedBox(height: 20),

                    _analyticsCard(),

                  ],

                  if (weakTopics.isNotEmpty) ...[

                    const SizedBox(height: 20),

                    _weakTopicsCard(),

                  ],

                  const SizedBox(height: 26),

                  _sectionTitle(

                    'Your Subjects',

                    'Choose a subject to explore its topics',

                  ),

                  const SizedBox(height: 14),

                  ...groupedTopics.entries.map(

                    (entry) => _subjectCard(

                      context,

                      entry.key,

                      entry.value,

                    ),

                  ),

                  if (groupedTopics.isEmpty)

                    _messageCard(

                      'No subjects or topics were found.',

                    ),

                  const SizedBox(height: 30),

                ],

              ),

            ),

    );

  }

  // ============================================================

  // HERO

  // ============================================================

  Widget _heroCard() {

    return Container(

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            Color(0xFF593AB9),

            Color(0xFF8066D9),

          ],

        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF593AB9).withValues(alpha: 0.20),

            blurRadius: 18,

            offset: const Offset(0, 8),

          ),

        ],

      ),

      child: const Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'LearnRoot',

            style: TextStyle(

              color: Colors.white,

              fontSize: 27,

              fontWeight: FontWeight.bold,

            ),

          ),

          SizedBox(height: 10),

          Text(

            'Assessment & Learning Analytics',

            style: TextStyle(

              color: Colors.white,

              fontSize: 18,

              fontWeight: FontWeight.w600,

            ),

          ),

          SizedBox(height: 7),

          Text(

            'Take quizzes, check your progress, read Smart AI Notes and explore learning videos.',

            style: TextStyle(

              color: Colors.white70,

              fontSize: 14,

              height: 1.4,

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================

  // SECTION TITLE

  // ============================================================

  Widget _sectionTitle(

    String title,

    String subtitle,

  ) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: const TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Color(0xFF27233A),

          ),

        ),

        const SizedBox(height: 4),

        Text(

          subtitle,

          style: TextStyle(

            color: Colors.grey.shade600,

            fontSize: 13,

          ),

        ),

      ],

    );

  }

  // ============================================================

  // SUBJECT CARD

  // ============================================================

  Widget _subjectCard(

    BuildContext context,

    String subject,

    List<Module4Topic> subjectTopics,

  ) {

    final icon = _subjectIcon(subject);

    final color = _subjectColor(subject);

    return Card(

      margin: const EdgeInsets.only(bottom: 14),

      elevation: 1.5,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(20),

      ),

      child: InkWell(

        borderRadius: BorderRadius.circular(20),

        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) => SubjectTopicsScreen(

                subject: subject,

                topics: subjectTopics,

              ),

            ),

          );

        },

        child: Padding(

          padding: const EdgeInsets.all(18),

          child: Row(

            children: [

              Container(

                width: 58,

                height: 58,

                decoration: BoxDecoration(

                  color: color.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(17),

                ),

                child: Icon(

                  icon,

                  color: color,

                  size: 29,

                ),

              ),

              const SizedBox(width: 16),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      subject,

                      style: const TextStyle(

                        fontSize: 17,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 5),

                    Text(

                      '${subjectTopics.length} topics available',

                      style: TextStyle(

                        color: Colors.grey.shade600,

                        fontSize: 13,

                      ),

                    ),

                  ],

                ),

              ),

              Container(

                padding: const EdgeInsets.all(9),

                decoration: BoxDecoration(

                  color: color.withValues(alpha: 0.10),

                  shape: BoxShape.circle,

                ),

                child: Icon(

                  Icons.arrow_forward_ios_rounded,

                  color: color,

                  size: 15,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  // ============================================================

  // SUBJECT ICON

  // ============================================================

  IconData _subjectIcon(String subject) {

    final name = subject.toLowerCase();

    if (name.contains('data structure')) {

      return Icons.account_tree_rounded;

    }

    if (name.contains('c programming')) {

      return Icons.code_rounded;

    }

    if (name.contains('operating system')) {

      return Icons.settings_system_daydream_rounded;

    }

    if (name.contains('computer network')) {

      return Icons.public_rounded;

    }

    if (name.contains('dbms')) {

      return Icons.storage_rounded;

    }

    if (name.contains('java') || name.contains('oop')) {

      return Icons.coffee_rounded;

    }

    return Icons.menu_book_rounded;

  }

  // ============================================================

  // SUBJECT COLOR

  // ============================================================

  Color _subjectColor(String subject) {

    final name = subject.toLowerCase();

    if (name.contains('data structure')) {

      return const Color(0xFF593AB9);

    }

    if (name.contains('c programming')) {

      return const Color(0xFF1976D2);

    }

    if (name.contains('operating system')) {

      return const Color(0xFFE65100);

    }

    if (name.contains('computer network')) {

      return const Color(0xFF00897B);

    }

    if (name.contains('dbms')) {

      return const Color(0xFF6A1B9A);

    }

    if (name.contains('java') || name.contains('oop')) {

      return const Color(0xFFD84315);

    }

    return const Color(0xFF455A64);

  }

  // ============================================================

  // ANALYTICS

  // ============================================================

  Widget _analyticsCard() {
    final a = analytics!;
    final attempts = '${a['total_attempts'] ?? 0}';
    final average = '${a['average_score'] ?? 0}%';
    final best = '${a['best_score'] ?? 0}%';
    final completed = '${a['completed_topics'] ?? 0}/${a['total_topics'] ?? 0}';
    final completedCount = int.tryParse('${a['completed_topics'] ?? 0}') ?? 0;
    final totalCount = int.tryParse('${a['total_topics'] ?? 0}') ?? 0;
    final progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF593AB9), Color(0xFF8066D9)]), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.insights_rounded, color: Colors.white, size: 26)),
            const SizedBox(width: 13),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Learning Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              Text('A quick look at your learning journey', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _analyticsStatCard(Icons.edit_note_rounded, 'Attempts', attempts, const Color(0xFF593AB9))),
            const SizedBox(width: 10),
            Expanded(child: _analyticsStatCard(Icons.trending_up_rounded, 'Average', average, const Color(0xFF00897B))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _analyticsStatCard(Icons.emoji_events_rounded, 'Best Score', best, const Color(0xFFE65100))),
            const SizedBox(width: 10),
            Expanded(child: _analyticsStatCard(Icons.task_alt_rounded, 'Completed', completed, const Color(0xFF6A1B9A))),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF7F5FC), borderRadius: BorderRadius.circular(17)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${(progress * 100).round()}%', style: const TextStyle(color: Color(0xFF593AB9), fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF593AB9)))),
            const SizedBox(height: 8),
            Text(progress >= .75 ? 'Amazing progress! Keep the momentum going.' : progress >= .4 ? 'Good progress! Keep exploring more topics.' : 'Start exploring topics and build your learning streak.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ])),
        ]),
      ),
    );
  }

  Widget _analyticsStatCard(IconData icon, String label, String value, Color color) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(17), border: Border.all(color: color.withValues(alpha: 0.10))), child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 21)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ])),
    ]));
  }

  // ============================================================

  // WEAK TOPICS

  // ============================================================

  Widget _weakTopicsCard() {
    return Card(elevation: 1.5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFF0E8), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.track_changes_rounded, color: Color(0xFFE65100), size: 26)),
        const SizedBox(width: 13),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Topics That Need Practice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text('Small gaps today, stronger concepts tomorrow', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
      ]),
      const SizedBox(height: 18),
      ...weakTopics.take(5).map((item) => _practiceTopicCard(item)),
    ])));
  }

  Widget _practiceTopicCard(Map<String, dynamic> item) {
    final score = int.tryParse('${item['percentage'] ?? 0}') ?? 0;
    final topicName = '${item['topic_name'] ?? 'Topic'}';
    final Color color;
    final String message;
    final IconData icon;
    if (score < 40) { color = const Color(0xFFD32F2F); message = 'Needs attention'; icon = Icons.priority_high_rounded; }
    else if (score < 60) { color = const Color(0xFFE65100); message = 'Keep practicing'; icon = Icons.trending_up_rounded; }
    else { color = const Color(0xFF2E7D32); message = 'Almost there'; icon = Icons.auto_awesome_rounded; }

    return Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: color.withValues(alpha: 0.14))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle), child: Icon(icon, color: color, size: 21)),
        const SizedBox(width: 11),
        Expanded(child: Text(topicName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(20)), child: Text('$score%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
      ]),
      const SizedBox(height: 11),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (score / 100).clamp(0.0, 1.0), minHeight: 7, backgroundColor: const Color(0xFFF0EEF5), valueColor: AlwaysStoppedAnimation<Color>(color))),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(message, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)), const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8066D9), size: 18)]),
    ]));
  }

// MESSAGE

  // ============================================================

  Widget _messageCard(String message) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Text(message),

      ),

    );

  }

}

// ==================================================================

// SUBJECT TOPICS SCREEN

// ==================================================================

class SubjectTopicsScreen extends StatelessWidget {

  final String subject;

  final List<Module4Topic> topics;

  const SubjectTopicsScreen({

    super.key,

    required this.subject,

    required this.topics,

  });

  @override

  Widget build(BuildContext context) {

    final sortedTopics = [...topics]

      ..sort(

        (a, b) => a.topicOrder.compareTo(b.topicOrder),

      );

    return Scaffold(

      backgroundColor: const Color(0xFFF7F5FC),

      appBar: AppBar(

        backgroundColor: Colors.white,

        title: Text(

          subject,

          style: const TextStyle(

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: ListView(

        padding: const EdgeInsets.all(18),

        children: [

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              gradient: const LinearGradient(

                colors: [

                  Color(0xFF593AB9),

                  Color(0xFF8066D9),

                ],

              ),

              borderRadius: BorderRadius.circular(20),

            ),

            child: Row(

              children: [

                const Icon(

                  Icons.menu_book_rounded,

                  color: Colors.white,

                  size: 32,

                ),

                const SizedBox(width: 14),

                Expanded(

                  child: Column(

                    crossAxisAlignment:

                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        subject,

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 20,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                      const SizedBox(height: 4),

                      Text(

                        '${sortedTopics.length} topics',

                        style: const TextStyle(

                          color: Colors.white70,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),

          const Text(

            'Topics',

            style: TextStyle(

              fontSize: 21,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 12),

          ...sortedTopics.map(

            (topic) => _topicCard(

              context,

              topic,

            ),

          ),

        ],

      ),

    );

  }

  Widget _topicCard(

    BuildContext context,

    Module4Topic topic,

  ) {

    return Card(

      margin: const EdgeInsets.only(bottom: 11),

      elevation: 1,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(17),

      ),

      child: Padding(

        padding: const EdgeInsets.all(14),

        child: Row(

          children: [

            Container(

              width: 45,

              height: 45,

              alignment: Alignment.center,

              decoration: BoxDecoration(

                color: const Color(0xFF593AB9).withValues(alpha: .10),

                borderRadius: BorderRadius.circular(13),

              ),

              child: Text(

                '${topic.topicOrder}',

                style: const TextStyle(

                  color: Color(0xFF593AB9),

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(width: 13),

            Expanded(

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  Text(

                    topic.topicName,

                    style: const TextStyle(

                      fontWeight: FontWeight.w600,

                      fontSize: 15,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    topic.topicCode.isEmpty

                        ? subject

                        : topic.topicCode,

                    style: TextStyle(

                      color: Colors.grey.shade600,

                      fontSize: 11,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(width: 8),

            FilledButton(

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => QuizScreen(

                      topic: topic,

                    ),

                  ),

                );

              },

              child: const Text('Quiz'),

            ),

          ],

        ),

      ),

    );

  }

}
