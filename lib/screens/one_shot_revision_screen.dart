import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';

class OneShotRevisionScreen extends StatefulWidget {
  final String subject;
  final String topic;

  const OneShotRevisionScreen({
    super.key,
    required this.subject,
    required this.topic,
  });

  @override
  State<OneShotRevisionScreen> createState() =>
      _OneShotRevisionScreenState();
}

class _OneShotRevisionScreenState
    extends State<OneShotRevisionScreen> {
  static const String _backendUrl = 'http://127.0.0.1:5000';

  bool _loading = true;
  String? _revision;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRevision();
  }

  Future<void> _loadRevision() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      http.Response response = await http.post(
        Uri.parse('$_backendUrl/revision'),
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': widget.subject,
          'topic': widget.topic,
        }),
      );

      // The currently verified backend also supports /summary.
      // Use it only if the older /revision route is unavailable.
      if (response.statusCode != 200) {
        response = await http.post(
          Uri.parse('$_backendUrl/summary'),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'subject': widget.subject,
            'topic': widget.topic,
          }),
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final value = data['revision'] ?? data['summary'];

        setState(() {
          _revision = _cleanRevisionText(value?.toString() ?? '');
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              'Unable to generate revision. Server returned status code ${response.statusCode}.';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not connect to the AI Tutor. Make sure the Flask backend is running on port 5000.';
        _loading = false;
      });
    }
  }

  String _cleanRevisionText(String value) {
    return value
        .replaceAll('â€¢', '•')
        .replaceAll('â€“', '–')
        .replaceAll('â€”', '—')
        .replaceAll('â€™', '’')
        .replaceAll('â€œ', '“')
        .replaceAll('â€', '”')
        .replaceAll('Ã—', '×')
        .replaceAll('Ã·', '÷')
        .replaceAll('Ã¢', 'â')
        .replaceAll('Â', '');
  }

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: AppBar(
        backgroundColor: themeColors.background,
        foregroundColor: themeColors.textPrimary,
        elevation: 0,
        title: Text('One-Shot Revision · ${widget.subject}'),
        actions: [
          IconButton(
            tooltip: 'Regenerate revision',
            onPressed: _loading ? null : _loadRevision,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? _buildLoading(context)
          : _error != null
              ? _buildError(context)
              : _buildRevision(context, scheme),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: themeColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: LearnRootColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                '⚡',
                style: TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing your one-shot revision',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.topic,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevision(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final text = _revision?.trim() ?? '';

    if (text.isEmpty) {
      return _buildErrorMessage(
        context,
        'The AI Tutor returned an empty revision. Please try again.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRevision,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        children: [
          _buildHero(context),
          const SizedBox(height: 16),
          _buildRevisionContent(context, text),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: scheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Use this page for a fast recap before attempting a quiz or continuing your learning path.',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final scheme = Theme.of(context).colorScheme;

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
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              '⚡',
              style: TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONE-SHOT REVISION',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.topic,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'A focused recap of the most important ideas, examples and exam points.',
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 11.5,
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

  Widget _buildRevisionContent(
    BuildContext context,
    String text,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];

    bool inCode = false;
    final code = StringBuffer();
    StringBuffer paragraph = StringBuffer();

    void flushParagraph() {
      final value = paragraph.toString().trim();
      if (value.isEmpty) {
        paragraph = StringBuffer();
        return;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _clean(value),
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      );
      paragraph = StringBuffer();
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      final trimmed = line.trim();

      if (trimmed.startsWith('```')) {
        if (!inCode) {
          flushParagraph();
          inCode = true;
          code.clear();
        } else {
          children.add(_buildCode(context, code.toString()));
          code.clear();
          inCode = false;
        }
        continue;
      }

      if (inCode) {
        code.writeln(line);
        continue;
      }

      if (trimmed.startsWith('#')) {
        flushParagraph();
        final heading = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        children.add(_buildHeading(context, heading));
        continue;
      }

      if (trimmed.isEmpty) {
        flushParagraph();
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        children.add(_buildBullet(context, trimmed.substring(2)));
        continue;
      }

      final match = RegExp(r'^(\d+)[.)]\s+(.*)$').firstMatch(trimmed);
      if (match != null) {
        flushParagraph();
        children.add(
          _buildNumbered(
            context,
            match.group(1)!,
            match.group(2)!,
          ),
        );
        continue;
      }

      paragraph.writeln(trimmed);
    }

    if (inCode && code.isNotEmpty) {
      children.add(_buildCode(context, code.toString()));
    }

    flushParagraph();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: themeColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHeading(
    BuildContext context,
    String title,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 5, bottom: 11),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Text(
        _clean(title),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBullet(
    BuildContext context,
    String text,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 7, right: 9),
            decoration: const BoxDecoration(
              color: LearnRootColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              _clean(text),
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbered(
    BuildContext context,
    String number,
    String text,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LearnRootColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: LearnRootColors.primary,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _clean(text),
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCode(
    BuildContext context,
    String code,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code.trimRight(),
          style: TextStyle(
            color: scheme.onSurface,
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return _buildErrorMessage(
      context,
      _error ?? 'Something went wrong.',
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    String message,
  ) {
    final themeColors =
        Theme.of(context).extension<LearnRootThemeColors>()!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: themeColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: scheme.error,
              size: 35,
            ),
            const SizedBox(height: 10),
            Text(
              'Revision unavailable',
              style: TextStyle(
                color: themeColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _loadRevision,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _clean(String value) {
    return value
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '')
        .trim();
  }
}
