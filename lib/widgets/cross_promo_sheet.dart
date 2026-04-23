import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalla/l10n/app_localizations.dart';

import '../theme/app_theme.dart';

/// Shows cached cross-promo games from [GameKit.crossPromo]; marks viewed when closed.
Future<void> showCrossPromoSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      final games = GameKit.crossPromo.getGames();
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scroll) {
          return Container(
            decoration: AppDecorations.bottomSheet,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    l10n.moreGames,
                    style: const TextStyle(
                      fontFamily: AppFonts.family,
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: games.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.crossPromoEmpty,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scroll,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: games.length,
                          itemBuilder: (context, i) {
                            final g = games[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: AppColors.cardFill,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Image.network(
                                        g.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.cardBorder,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.games,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    g.title,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.family,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.open_in_new,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onTap: () async {
                                    final uri = Uri.tryParse(g.link);
                                    if (uri != null && await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  await GameKit.crossPromo.markGamesViewed();
}
