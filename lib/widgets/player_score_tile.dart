import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class PlayerScoreTile extends StatelessWidget {
  final Player player;
  final int rank;
  final bool isWinner;

  const PlayerScoreTile({
    super.key,
    required this.player,
    required this.rank,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isWinner ? AppColors.coin.withValues(alpha: 0.15) : AppColors.cardFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isWinner
            ? Border.all(color: AppColors.coin, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _rankColor,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.emoji_events, color: AppColors.coin, size: 24),
            ),
          Text(
            '${player.score}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color get _rankColor {
    return switch (rank) {
      1 => Colors.amber.shade700,
      2 => Colors.grey.shade500,
      3 => Colors.brown.shade400,
      _ => Colors.blueGrey,
    };
  }
}
