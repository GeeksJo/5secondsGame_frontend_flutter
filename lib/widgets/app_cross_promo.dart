import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:yalla/l10n/app_localizations.dart';

/// Opens [GameKit] cross-promo catalog (bottom sheet). Tint is [GameKit.crossPromoSheetSeedColor].
Future<void> showAppCrossPromoSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showCrossPromotionBottomSheet(
    context,
    strings: CrossPromoSheetStrings(
      title: l10n.moreGames,
      subtitle: l10n.moreGamesSubtitle,
      openLabel: l10n.crossPromoOpen,
      emptyTitle: l10n.crossPromoEmpty,
      emptySubtitle: l10n.crossPromoEmpty,
    ),
  );
}
