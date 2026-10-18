import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


import '../models/topic.dart';


class VideoResourcesScreen extends StatelessWidget {
  final Module4Topic topic;

  const VideoResourcesScreen({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final resources = [
      _VideoResource(
        icon: '🌱',
        title: 'Beginner Introduction',
        subtitle: 'Start with the basics and build a clear foundation.',
        query: '${topic.topicName} beginner tutorial',
        accent: scheme.primary,
      ),
      _VideoResource(
        icon: '🧠',
        title: 'Concept Explanation',
        subtitle: 'Understand the main concepts in simple language.',
        query: '${topic.topicName} explained simply',
        accent: Colors.blue,
      ),
      _VideoResource(
        icon: '💻',
        title: 'Practical Example',
        subtitle: 'Learn the topic through examples and demonstrations.',
        query: '${topic.topicName} practical examples',
        accent: Colors.green,
      ),
      _VideoResource(
        icon: '🎯',
        title: 'Exam Revision',
        subtitle: 'Revise important points before your exam.',
        query: '${topic.topicName} exam revision',
        accent: Colors.orange,
      ),
      _VideoResource(
        icon: '⚙️',
        title: 'Detailed Working',
        subtitle: 'Go deeper into how the concept works.',
        query: '${topic.topicName} detailed explanation',
        accent: Colors.deepPurple,
      ),
      _VideoResource(
        icon: '🔥',
        title: 'Quick Revision',
        subtitle: 'Refresh the topic quickly in a short session.',
        query: '${topic.topicName} quick revision',
        accent: Colors.redAccent,
      ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('YouTube Recommended Videos'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              30,
            ),
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),

              Text(
                'Explore ${topic.topicName}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Choose what you want to learn and open a focused YouTube search.',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              wide
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resources.length,
                     gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  mainAxisExtent: 150,
),
                      itemBuilder: (context, index) {
                        return _buildResourceCard(
                          context,
                          resources[index],
                        );
                      },
                    )
                  : Column(
                      children: resources.map((resource) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildResourceCard(
                            context,
                            resource,
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 8),
              _buildFooterNote(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '▶️',
              style: TextStyle(
                fontSize: 27,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUTUBE RECOMMENDED VIDEOS',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  topic.topicName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a learning goal and continue with focused video resources.',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withValues(
                      alpha: 0.72,
                    ),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    _VideoResource resource,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openYouTube(context, resource.query),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: resource.accent.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  resource.icon,
                  style: const TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      resource.subtitle,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: resource.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Search on YouTube',
                          style: TextStyle(
                            color: resource.accent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.open_in_new_rounded,
                color: scheme.onSurface.withValues(
                  alpha: 0.48,
                ),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: scheme.primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'LearnRoot opens a focused YouTube search for the selected learning goal. Choose videos that match your syllabus and learning level.',
              style: TextStyle(
                color: scheme.onSurface.withValues(
                  alpha: 0.70,
                ),
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openYouTube(
    BuildContext context,
    String query,
  ) async {
    final uri = Uri.https(
      'www.youtube.com',
      '/results',
      {
        'search_query': query,
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open YouTube.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open YouTube.',
          ),
        ),
      );
    }
  }
}

class _VideoResource {
  final String icon;
  final String title;
  final String subtitle;
  final String query;
  final Color accent;

  const _VideoResource({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.query,
    required this.accent,
  });
}