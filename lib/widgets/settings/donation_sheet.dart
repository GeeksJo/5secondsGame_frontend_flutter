import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/game_kit_products.dart';
import '../../services/purchase_service.dart';
import '../../theme/app_theme.dart';

Future<void> showDonationTierSheet({
  required BuildContext context,
  required PurchaseService purchases,
  required AppLocalizations l10n,
  required bool purchasing,
  required void Function(String productId) onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      Widget tier({
        required String productId,
        required String label,
        required Color accent,
        required IconData icon,
      }) {
        final price = purchases.getFormattedPrice(productId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: purchasing
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      onPick(productId);
                    },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.35),
                      accent.withValues(alpha: 0.12),
                    ],
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.65)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textPrimary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return Directionality(
        textDirection: Directionality.of(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          child: DecoratedBox(
            decoration: AppDecorations.bottomSheet,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.donationPickTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.family,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  tier(
                    productId: GameKitProducts.donationSmall,
                    label: l10n.supportSmall,
                    accent: const Color(0xFF1E88E5),
                    icon: Icons.favorite_border_rounded,
                  ),
                  tier(
                    productId: GameKitProducts.donationMedium,
                    label: l10n.supportMedium,
                    accent: const Color(0xFF43A047),
                    icon: Icons.favorite_rounded,
                  ),
                  tier(
                    productId: GameKitProducts.donationLarge,
                    label: l10n.supportLarge,
                    accent: const Color(0xFFFF9800),
                    icon: Icons.volunteer_activism_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
