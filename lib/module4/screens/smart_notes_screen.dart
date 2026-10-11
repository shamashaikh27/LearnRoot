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
  String? notes;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final value = await Module4Api.getAiNotesByTopicName(
        widget.topic.topicName,
      );

      if (!mounted) return;

      setState(() {
        notes = value;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Smart AI Notes'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh notes',
            onPressed: loading ? null : loadNotes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? _buildError(context)
              : _buildNotes(context),
    );
  }

  Widget _buildNotes(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final rawNotes = notes?.trim() ?? '';

    if (rawNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No notes were generated for this topic.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.70),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final parsed = _parseNotes(rawNotes);

    return RefreshIndicator(
      onRefresh: loadNotes,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          14,
          18,
          32,
        ),
        children: [
          _buildHero(context),
          const SizedBox(height: 14),
          _buildLearningStrip(context),
          const SizedBox(height: 22),
          ...parsed,
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: const Text(
              '🧠',
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
                  'SMART AI NOTES',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.topic.topicName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Structured notes for learning, revision and exam preparation.',
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

  Widget _buildLearningStrip(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final items = [
      ('📖', 'Learn'),
      ('⭐', 'Remember'),
      ('🎯', 'Exam'),
      ('🔥', 'Revise'),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _parseNotes(String text) {
    final lines = text.replaceAll('\r\n', '\n').split('\n');

    final widgets = <Widget>[];

    String? currentHeading;
    StringBuffer body = StringBuffer();
    bool inCodeBlock = false;
    StringBuffer codeBuffer = StringBuffer();

    void flushBody() {
      final content = body.toString().trim();

      if (content.isEmpty) {
        body = StringBuffer();
        return;
      }

      if (currentHeading != null) {
        widgets.add(
          _buildSection(
            context,
            title: currentHeading!,
            content: content,
          ),
        );
      } else {
        widgets.add(
          _buildPlainText(
            context,
            content,
          ),
        );
      }

      body = StringBuffer();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();

      if (line.trim().startsWith('```')) {
        if (!inCodeBlock) {
          flushBody();
          inCodeBlock = true;
          codeBuffer = StringBuffer();
        } else {
          widgets.add(
            _buildCodeBlock(
              context,
              codeBuffer.toString().trimRight(),
            ),
          );
          codeBuffer = StringBuffer();
          inCodeBlock = false;
        }
        continue;
      }

      if (inCodeBlock) {
        codeBuffer.writeln(line);
        continue;
      }

      if (line.startsWith('# ')) {
        flushBody();

        final title = line
            .substring(2)
            .trim()
            .replaceAll(RegExp(r'^🧠\s*'), '');

        if (title.isNotEmpty) {
          widgets.add(
            _buildMainHeading(
              context,
              title,
            ),
          );
        }

        currentHeading = null;
        continue;
      }

      if (line.startsWith('## ')) {
        flushBody();

        currentHeading = line
            .substring(3)
            .trim();

        continue;
      }

      if (line.startsWith('### ')) {
        flushBody();

        currentHeading = line
            .substring(4)
            .trim();

        continue;
      }

      if (line.trim().isEmpty) {
        if (body.isNotEmpty) {
          body.writeln();
        }
        continue;
      }

      body.writeln(line);
    }

    if (inCodeBlock && codeBuffer.isNotEmpty) {
      widgets.add(
        _buildCodeBlock(
          context,
          codeBuffer.toString().trimRight(),
        ),
      );
    }

    flushBody();

    widgets.add(
      const SizedBox(height: 18),
    );

    widgets.add(
      _buildRevisionCard(context),
    );

    return widgets;
  }

  Widget _buildMainHeading(
    BuildContext context,
    String title,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final cleanTitle = _cleanHeading(title);

    final isIntroduction =
        cleanTitle.toLowerCase().contains('introduction');

    final isConcepts =
        cleanTitle.toLowerCase().contains('important concepts');

    final isExample =
        cleanTitle.toLowerCase().contains('example');

    final isRevision =
        cleanTitle.toLowerCase().contains('revision');

    final accent = isConcepts
        ? Colors.green
        : isExample
            ? Colors.orange
            : isRevision
                ? Colors.blue
                : scheme.primary;

    final icon = isIntroduction
        ? '🚀'
        : isConcepts
            ? '🧩'
            : isExample
                ? '💻'
                : isRevision
                    ? '⚡'
                    : '📘';

    final parsedLines = _contentWidgets(
      context,
      content,
      accent,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 19,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  cleanTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...parsedLines,
        ],
      ),
    );
  }

  List<Widget> _contentWidgets(
    BuildContext context,
    String content,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final widgets = <Widget>[];

    final lines = content
        .replaceAll('\r\n', '\n')
        .split('\n');

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        widgets.add(
          const SizedBox(height: 6),
        );
        continue;
      }

      if (line.startsWith('- ') ||
          line.startsWith('* ')) {
        final text = line.substring(2).trim();

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(
                    top: 6,
                    right: 9,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    _cleanInline(text),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(
                        alpha: 0.76,
                      ),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        continue;
      }

      final numberedMatch = RegExp(
        r'^(\d+)[.)]\s+(.*)$',
      ).firstMatch(line);

      if (numberedMatch != null) {
        final number = numberedMatch.group(1)!;
        final text = numberedMatch.group(2)!;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 9,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _cleanInline(text),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        continue;
      }

      if (line.startsWith('Definition:')) {
        final text = line
            .substring('Definition:'.length)
            .trim();

        widgets.add(
          _buildCallout(
            context,
            label: 'Definition',
            icon: Icons.menu_book_rounded,
            color: accent,
            text: text,
          ),
        );

        continue;
      }

      if (line.startsWith('🎯 Key idea:')) {
        final text = line
            .substring('🎯 Key idea:'.length)
            .trim();

        widgets.add(
          _buildCallout(
            context,
            label: 'Key idea',
            icon: Icons.lightbulb_rounded,
            color: accent,
            text: text,
          ),
        );

        continue;
      }

      if (line.startsWith('🎯 Exam point:')) {
        final text = line
            .substring('🎯 Exam point:'.length)
            .trim();

        widgets.add(
          _buildCallout(
            context,
            label: 'Exam point',
            icon: Icons.school_rounded,
            color: Colors.orange,
            text: text,
          ),
        );

        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            bottom: 7,
          ),
          child: Text(
            _cleanInline(line),
            style: TextStyle(
              color: scheme.onSurface.withValues(
                alpha: 0.76,
              ),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCallout(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanInline(text),
                  style: TextStyle(
                    color: scheme.onSurface.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(
    BuildContext context,
    String code,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: TextStyle(
            color: scheme.onSurface,
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.55,
          ),
        ),
      ),
    );
  }

  Widget _buildPlainText(
    BuildContext context,
    String text,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Text(
        _cleanInline(text),
        style: TextStyle(
          color: scheme.onSurface.withValues(
            alpha: 0.76,
          ),
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildRevisionCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '⚡',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Quick Revision',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            'Read the highlighted points once more before moving to the quiz or your next learning resource.',
            style: TextStyle(
              color: scheme.onPrimaryContainer.withValues(
                alpha: 0.74,
              ),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.error.withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: scheme.onErrorContainer,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'Unable to load notes',
                style: TextStyle(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                error ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onErrorContainer.withValues(
                    alpha: 0.80,
                  ),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: loadNotes,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanHeading(String text) {
    return text
        .replaceAll(RegExp(r'^\d+\.\s*'), '')
        .trim();
  }

  String _cleanInline(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '')
        .trim();
  }
}