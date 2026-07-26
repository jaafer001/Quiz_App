import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

class QuizProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const QuizProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalCount > 0 ? (currentIndex + 1) / totalCount : 0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: AppTheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          "${currentIndex + 1} of $totalCount",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
