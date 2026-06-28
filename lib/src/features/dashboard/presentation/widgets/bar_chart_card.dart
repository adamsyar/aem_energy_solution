import 'package:flutter/material.dart';

import '../../domain/models/chart_item.dart';

class BarChartCard extends StatelessWidget {
  const BarChartCard({super.key, required this.items});

  final List<ChartItem> items;

  static const _palette = [
    Color(0xFF4C51E8),
    Color(0xFF36C36B),
    Color(0xFFFF5353),
    Color(0xFF31B97B),
    Color(0xFFFF4C4C),
    Color(0xFF42C76F),
    Color(0xFF4C51E8),
  ];

  static const _fallback = [
    ChartItem(name: 'Bar 1', value: 30),
    ChartItem(name: 'Bar 2', value: 60),
    ChartItem(name: 'Bar 3', value: 56),
    ChartItem(name: 'Bar 4', value: 27),
    ChartItem(name: 'Bar 5', value: 5),
    ChartItem(name: 'Bar 6', value: 29),
    ChartItem(name: 'Bar 7', value: 34),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = items.isEmpty ? _fallback : items;
    final maxValue = values
        .map((item) => item.value)
        .fold<double>(
          0,
          (previous, element) => element > previous ? element : previous,
        );

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
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: AspectRatio(
          aspectRatio: 1.55,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final barCount = values.length;
              final gap = 14.0;
              final barWidth =
                  ((totalWidth - (gap * (barCount - 1))) / barCount).clamp(
                    22.0,
                    34.0,
                  );

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  final item = values[index];
                  final heightFactor = maxValue == 0
                      ? 0.0
                      : item.value / maxValue;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == values.length - 1 ? 0 : gap,
                    ),
                    child: SizedBox(
                      width: barWidth,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: heightFactor),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutBack,
                          builder: (context, animatedValue, child) {
                            return FractionallySizedBox(
                              heightFactor: animatedValue
                                  .clamp(0.08, 1.0)
                                  .toDouble(),
                              child: child,
                            );
                          },
                          child: SizedBox.expand(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _palette[index % _palette.length],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _palette[index % _palette.length]
                                        .withValues(alpha: 0.26),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
