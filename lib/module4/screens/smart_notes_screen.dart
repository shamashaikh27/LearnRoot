import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../services/module4_api.dart';

class SmartNotesScreen extends StatefulWidget {
  final Module4Topic topic;

  const SmartNotesScreen({
    super.key,
    required this.topic,
  });

  @override
  State<SmartNotesScreen> createState() => _SmartNotesScreenState();
}

class _SmartNotesScreenState extends State<SmartNotesScreen> {
  bool loading = true;
  String? error;
  String notes = '';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final value =
          await Module4Api.getAiNotes(widget.topic.topicId);

      if (!mounted) return;

      setState(() {
        notes = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart AI Notes'),
      ),
      body: loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading Smart Notes...'),
                ],
              ),
            )
          : error != null
              ? _errorView()
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF593AB9),
                            Color(0xFF7B61D1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 38,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.topic.topicName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _notesContent(context, notes),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50),
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loadNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesContent(BuildContext context, String value) {
    final lines = value.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((raw) {
        final line = raw.trim();

        if (line.isEmpty) {
          return const SizedBox(height: 10);
        }

        if (line == '---' || line == '***' || line == '___') {
          return const Divider(height: 24);
        }

        if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line.substring(2),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }

        if (line.startsWith('- ') ||
            line.startsWith('* ') ||
            line.startsWith('• ')) {
          final clean = line.substring(2).trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(clean)),
              ],
            ),
          );
        }

        final cleaned = line.replaceAll('**', '').replaceAll('`', '');

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            cleaned,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }).toList(),
    );
  }
}
