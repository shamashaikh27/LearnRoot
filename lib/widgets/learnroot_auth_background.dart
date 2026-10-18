import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Subtle animated learning-network background shared by auth screens.
class LearnRootAuthBackground extends StatefulWidget {
  final bool isDark;

  const LearnRootAuthBackground({super.key, required this.isDark});

  @override
  State<LearnRootAuthBackground> createState() =>
      _LearnRootAuthBackgroundState();
}

class _LearnRootAuthBackgroundState extends State<LearnRootAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _LearnRootNetworkPainter(
          progress: _controller.value,
          isDark: widget.isDark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _LearnRootNetworkPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _LearnRootNetworkPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final purple = const Color(0xFF8267FF);
    final blue = const Color(0xFF4A78FF);
    final glowRadius = math.min(size.width, size.height).toDouble() * .38;

    void drawGlow(double x, double y, Color color, double phase) {
      final center = Offset(
        size.width * x + math.sin(progress * math.pi * 2 + phase) * 22,
        size.height * y + math.cos(progress * math.pi * 2 + phase) * 18,
      );
      final rect = Rect.fromCircle(center: center, radius: glowRadius);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: isDark ? .16 : .10),
            color.withValues(alpha: isDark ? .055 : .035),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawCircle(center, glowRadius, paint);
    }

    drawGlow(.12, .18, purple, .3);
    drawGlow(.88, .76, blue, 2.1);
    drawGlow(.72, .12, purple, 4.2);

    final points = <Offset>[];
    for (var i = 0; i < 30; i++) {
      final x = ((i * 37 + 13) % 101) / 100.0;
      final y = ((i * 61 + 19) % 103) / 102.0;
      points.add(
        Offset(
          x * size.width + math.sin(progress * math.pi * 2 + i * .7) * 13,
          y * size.height + math.cos(progress * math.pi * 2 + i * .53) * 12,
        ),
      );
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = purple.withValues(alpha: isDark ? .13 : .10);

    final maxDistance = math.min(size.width, size.height).toDouble() * .22;
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        if ((points[i] - points[j]).distance < maxDistance) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    final dotPaint = Paint()
      ..color = (isDark ? const Color(0xFFB7ABFF) : purple).withValues(
        alpha: isDark ? .35 : .20,
      );
    for (var i = 0; i < points.length; i++) {
      final pulse = .9 + .65 * (math.sin(progress * math.pi * 2 + i) + 1) / 2;
      canvas.drawCircle(points[i], 1.2 * pulse, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LearnRootNetworkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
