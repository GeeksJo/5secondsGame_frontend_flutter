import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:game_kit/game_kit.dart';

import '../providers/game_provider.dart';
import '../services/ad_service.dart';
import '../services/game_kit_bootstrap.dart';
import '../theme/app_theme.dart';
import '../widgets/player_score_tile.dart';
import '../widgets/responsive_layout.dart';
import 'category_selection_screen.dart';
import 'home_screen.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _adShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _adShowing = true);
      final ads = context.read<AdService>();
      await GameKit.notifications.onFirstDailyCompletion();
      await GameKitAdBridge.presentAfterLevel(ads, failed: false);
      GameKit.haptics.levelComplete();
      if (mounted) setState(() => _adShowing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();
    final ranked = game.rankedPlayers;
    final isTablet = ResponsiveLayout.isTablet(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppDecorations.gradientBg,
          child: SafeArea(
            child: ResponsiveLayout(
              maxWidth: 560,
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 28 : 20),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 18 : 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardFill,
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.coin,
                      size: isTablet ? 44 : 36,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  Text(
                    l10n.scoreboard,
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 32.0 : 26.0,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.score,
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      color: AppColors.textMuted,
                      fontSize: isTablet ? 15.0 : 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: isTablet ? 22 : 18),
                  Expanded(
                    child: ListView.separated(
                      padding: AppSpacing.screenH.copyWith(bottom: 8),
                      itemCount: ranked.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return PlayerScoreTile(
                          player: ranked[index],
                          rank: index + 1,
                          isWinner: index == 0,
                          isTablet: isTablet,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.screenPadding.copyWith(top: 8),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _adShowing
                                ? null
                                : () {
                                    game.resetGame();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CategorySelectionScreen(),
                                      ),
                                      (route) => route.isFirst,
                                    );
                                  },
                            style: AppButtonStyles.primary,
                            child: Text(l10n.playAgain),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _adShowing
                              ? null
                              : () async {
                                  final ads = context.read<AdService>();
                                  final nav = Navigator.of(context);
                                  setState(() => _adShowing = true);
                                  try {
                                    await GameKitAdBridge.presentOnAbandonHome(
                                      ads,
                                    );
                                  } finally {
                                    if (!context.mounted) return;
                                    nav.pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                          child: Text(
                            l10n.home,
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 17.0 : 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
