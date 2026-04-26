import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:yalla/l10n/app_localizations.dart';

import '../theme/app_theme.dart';

/// Opens [GameKit] cross-promo catalog (bottom sheet) with app l10n + theme.
Future<void> showAppCrossPromoSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showCrossPromotionBottomSheet(
    context,
    primaryColor: AppColors.primary,
    strings: CrossPromoSheetStrings(
      title: l10n.moreGames,
      subtitle: l10n.moreGamesSubtitle,
      openLabel: l10n.crossPromoOpen,
      emptyTitle: l10n.crossPromoEmpty,
      emptySubtitle: l10n.crossPromoEmpty,
    ),
  );
}
