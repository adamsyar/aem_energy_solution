import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/chart_item.dart';

class DonutChartCard extends StatelessWidget {
  const DonutChartCard({super.key, required this.items});

  final List<ChartItem> items;

  static const _palette = [
    Color(0xFF4750E7),
    Color(0xFF39C97A),
    Color(0xFFFF5A53),
    Color(0xFF4750E7),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = items;

    if (values.isEmpty) {
      return Card(
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: theme.cardTheme.shadowColor ?? theme.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: AspectRatio(
            aspectRatio: 1.44,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.donut_large_rounded,
                    size: 34,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No donut chart data available.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.76,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: theme.cardTheme.shadowColor ?? theme.shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: AspectRatio(
          aspectRatio: 1.44,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.78,
              heightFactor: 0.78,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) {
                  return CustomPaint(
                    painter: _DonutPainter(
                      items: values,
                      colors: _palette,
                      trackColor: theme.dividerColor.withValues(alpha: 0.7),
                      progress: progress,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  static const _separatorRadians = 0.04;

  _DonutPainter({
    required this.items,
    required this.colors,
    required this.trackColor,
    required this.progress,
  });

  final List<ChartItem> items;
  final List<Color> colors;
  final Color trackColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.19;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = trackColor;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    var startAngle = -math.pi / 2;
    for (var index = 0; index < items.length; index++) {
      final fullSweep = (items[index].value / total) * math.pi * 2 * progress;
      final adjustedSweep = math.max(0.0, fullSweep - _separatorRadians);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = colors[index % colors.length];
      canvas.drawArc(
        rect,
        startAngle + (_separatorRadians / 2),
        adjustedSweep,
        false,
        paint,
      );
      startAngle += (items[index].value / total) * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.progress != progress;
  }
}
