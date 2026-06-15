import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:provider/provider.dart';
import 'package:yalla/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_cross_promo.dart';
import '../widgets/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const double _sectionSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isTablet = ResponsiveLayout.isTablet(context);
    final palette = GameKit.settingsUi != null
        ? GameKitSettingsPalette.fromUiConfig(GameKit.settingsUi!)
        : GameKitSettingsPalette.fromSeed(
            AppColors.primary,
            fontFamily: AppFonts.family,
            sectionCardAppearance: GameKitSectionCardAppearance.frosted,
          );

    final maxW = ResponsiveLayout.maxWidthFor(
      context,
      phone: double.infinity,
      tabletPortrait: 640,
      tabletLandscape: 760,
    );
    final hPad = ResponsiveLayout.tabletContentHorizontalInset(context);

    final listPad = isTablet
        ? const EdgeInsets.fromLTRB(12, 24, 12, 24)
        : EdgeInsets.symmetric(vertical: 16.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontFamily: AppFonts.family,
            fontSize: isTablet ? 30 : null,
            fontWeight: isTablet ? FontWeight.w700 : null,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: ResponsiveLayout(
            maxWidth: maxW,
            child: ListView(
              padding: listPad,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      GameKitSettingSectionWidget(
                        palette: palette,
                        margin: EdgeInsets.zero,
                        headerIcon: Icons.apps_rounded,
                        headerTitle: l10n.sectionAppInfo,
                        fontFamily: AppFonts.family,
                        child: GameKitSettingItem(
                          palette: palette,
                          fontFamily: AppFonts.family,
                          icon: Icons.celebration_outlined,
                          title: l10n.appName,
                          subtitle: l10n.appInfoLine,
                          showDivider: false,
                        ),
                      ),
                      SizedBox(height: _sectionSpacing),
                      GameKitSettingSectionWidget(
                        palette: palette,
                        margin: EdgeInsets.zero,
                        fontFamily: AppFonts.family,
                        child: _soundTile(context, localeProvider, palette),
                      ),
                      SizedBox(height: _sectionSpacing),
                      _MoreGamesCard(
                        isTablet: isTablet,
                        title: l10n.moreGames,
                        subtitle: l10n.moreGamesSubtitle,
                        onTap: () => showAppCrossPromoSheet(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _sectionSpacing),
                const GameKitSettingsBody(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  sectionSpacing: _sectionSpacing,
                  maxWidth: double.infinity,
                ),
                // if (kDebugMode) ...[
                //   SizedBox(height: _sectionSpacing),
                //   ListTile(
                //     leading: Icon(
                //       Icons.leaderboard_outlined,
                //       color: AppColors.textSecondary,
                //       size: isTablet ? 32 : 24,
                //     ),
                //     title: Text(
                //       'Preview results (debug)',
                //       style: TextStyle(
                //         fontFamily: AppFonts.family,
                //         color: AppColors.textPrimary,
                //         fontWeight: FontWeight.w600,
                //         fontSize: isTablet ? 22 : null,
                //       ),
                //     ),
                //     subtitle: Text(
                //       'Scoreboard test data',
                //       style: TextStyle(
                //         fontFamily: AppFonts.family,
                //         color: AppColors.textMuted,
                //         fontSize: isTablet ? 17 : 12,
                //       ),
                //     ),
                //     onTap: () {
                //       Navigator.of(context).push(
                //         MaterialPageRoute<void>(
                //           builder: (_) => ScoreboardScreen(
                //             debugRankedPlayers:
                //                 ScoreboardScreenTestData.rankedPlayersFixture(),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _soundTile(
    BuildContext context,
    LocaleProvider localeProvider,
    GameKitSettingsPalette palette,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GameKitSettingItem(
      palette: palette,
      fontFamily: AppFonts.family,
      icon: localeProvider.soundEnabled ? Icons.volume_up : Icons.volume_off,
      title: l10n.sound,
      showDivider: false,
      trailing: Switch(
        value: localeProvider.soundEnabled,
        onChanged: (_) => localeProvider.toggleSound(),
        activeTrackColor: AppColors.textHint,
        activeThumbColor: AppColors.textPrimary,
      ),
    );
  }
}

class _MoreGamesCard extends StatelessWidget {
  final bool isTablet;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreGamesCard({
    required this.isTablet,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = isTablet ? 22.0 : 16.0;
    final subtitleSize = isTablet ? 17.0 : 12.5;
    final hPad = isTablet ? 22.0 : 16.0;
    final vPad = isTablet ? 18.0 : 14.0;
    final iconBox = isTablet ? 54.0 : 44.0;
    final innerPad = isTablet ? 10.0 : 8.0;
    final gap = isTablet ? 16.0 : 12.0;
    final chevron = isTablet ? 32.0 : 26.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: Row(
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      AppRadius.round(context),
                    ),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(innerPad),
                    child: Image.asset(
                      'assets/images/game_controller.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: titleSize,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: subtitleSize,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
