import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class PlayerScoreTile extends StatelessWidget {
  final Player player;
  final int rank;
  final bool isWinner;
  final bool isTablet;

  const PlayerScoreTile({
    super.key,
    required this.player,
    required this.rank,
    this.isWinner = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final nameSize = isTablet ? 18.0 : 16.0;
    final scoreSize = isTablet ? 26.0 : 22.0;
    final badge = isTablet ? 40.0 : 36.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 18 : 14,
      ),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.coin.withValues(alpha: 0.12)
            : AppColors.cardFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isWinner
              ? AppColors.coin.withValues(alpha: 0.85)
              : AppColors.cardBorder.withValues(alpha: 0.9),
          width: isWinner ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: badge,
            height: badge,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _rankColor,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? 17 : 15,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Text(
              player.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.textPrimary,
                fontSize: nameSize,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
          if (isWinner) ...[
            Icon(
              Icons.emoji_events_rounded,
              color: AppColors.coin.withValues(alpha: 0.95),
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 10 : 8),
          ],
          Text(
            '${player.score}',
            style: TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textPrimary,
              fontSize: scoreSize,
              fontWeight: FontWeight.w800,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Color get _rankColor {
    return switch (rank) {
      1 => Colors.amber.shade700,
      2 => Colors.blueGrey.shade400,
      3 => Colors.brown.shade400,
      _ => Colors.blueGrey.shade600,
    };
  }
}
