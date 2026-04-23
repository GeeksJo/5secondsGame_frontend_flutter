import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/coin_provider.dart';
import '../theme/app_theme.dart';

class LockedCategorySheet extends StatelessWidget {
  final GameCategory category;

  const LockedCategorySheet({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coinProvider = context.watch<CoinProvider>();

    return Container(
      padding: AppSpacing.screenPadding,
      decoration: AppDecorations.bottomSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(category.icon, color: category.color, size: 48),
          const SizedBox(height: 8),
          Text(
            category.name(Localizations.localeOf(context).languageCode),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: AppColors.coin, size: 18),
              const SizedBox(width: 4),
              Text(
                '${coinProvider.coins} ${l10n.coins}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOption(
            context,
            icon: Icons.timer,
            label: l10n.rentFor2Hours,
            cost: '${CoinProvider.rentCost}',
            enabled: coinProvider.coins >= CoinProvider.rentCost,
            onTap: () async {
              final success = await coinProvider.rentCategory(category.key);
              if (context.mounted) {
                Navigator.pop(context, success);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.star,
            label: l10n.buyForever,
            cost: '${CoinProvider.buyCost}',
            enabled: coinProvider.coins >= CoinProvider.buyCost,
            onTap: () async {
              final success = await coinProvider.buyCategory(category.key);
              if (context.mounted) {
                Navigator.pop(context, success);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.play_circle_fill,
            label: '${l10n.watchAd} — ${l10n.earnCoins}',
            cost: '+${CoinProvider.adReward}',
            enabled: coinProvider.isAdReady,
            isAd: true,
            onTap: () async {
              if (!GameKit.ads.canShowRewarded(RewardedReason.hint)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.rewardedUnavailable),
                    ),
                  );
                }
                return;
              }
              await coinProvider.watchAdForCoins();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String cost,
    required bool enabled,
    required VoidCallback onTap,
    bool isAd = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? AppColors.cardFill : AppColors.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: enabled ? AppColors.cardBorder : AppColors.cardFill,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? AppColors.textPrimary : AppColors.textHint, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  color: enabled ? AppColors.textPrimary : AppColors.textHint,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAd ? Icons.play_arrow : Icons.monetization_on,
                  color: isAd
                      ? (enabled ? AppColors.correct : AppColors.textHint)
                      : AppColors.coin,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  cost,
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    color: enabled ? AppColors.textPrimary : AppColors.textHint,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
