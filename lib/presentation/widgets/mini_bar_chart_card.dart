import 'dart:math';

import 'package:flutter/material.dart';

class MiniBarChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<int> data;
  final int maxValue;
  final Color barColor;

  const MiniBarChartCard({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.maxValue,
    required this.barColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      data.map((value) {
                        final heightPercentage = (value / maxValue).clamp(
                          0.0,
                          1.0,
                        );
                        final barHeight = max(
                          constraints.maxHeight * 0.05,
                          constraints.maxHeight * heightPercentage,
                        );

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
