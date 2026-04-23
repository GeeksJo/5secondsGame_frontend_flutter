import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountdownTimer extends StatelessWidget {
  final double progress;
  final int secondsLeft;
  final bool isIntro;
  final double diameter;

  const CountdownTimer({
    super.key,
    required this.progress,
    required this.secondsLeft,
    this.isIntro = false,
    this.diameter = 120,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isIntro) {
      color = secondsLeft <= 1 ? AppColors.danger : AppColors.coin;
    } else {
      color = secondsLeft <= 2 ? AppColors.danger : AppColors.textPrimary;
    }
    final fontSize = isIntro ? diameter * 0.4 : diameter * 0.36;
    final stroke = isIntro ? 8.0 : 7.0;
    final ring = diameter * 0.92;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ring,
            height: ring,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              fontFamily: AppFonts.family,
              color: color,
              fontSize: fontSize.clamp(32, 52),
              fontWeight: FontWeight.w800,
              height: 1,
              shadows: isIntro
                  ? [
                      Shadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
