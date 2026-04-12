import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountdownTimer extends StatelessWidget {
  final double progress;
  final int secondsLeft;

  const CountdownTimer({
    super.key,
    required this.progress,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final color = secondsLeft <= 2 ? AppColors.danger : AppColors.textPrimary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
