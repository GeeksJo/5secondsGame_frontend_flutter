import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/ad_service.dart';
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
      await context.read<AdService>().showInterstitial();
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
              maxWidth: 600,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.emoji_events, color: AppColors.coin,
                      size: isTablet ? 80 : 64),
                  const SizedBox(height: 8),
                  Text(
                    l10n.scoreboard,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 34.0 : 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.coin, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.coinsEarned}: ${game.coinsEarnedThisGame}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      padding: AppSpacing.screenH,
                      itemCount: ranked.length,
                      itemBuilder: (context, index) {
                        return PlayerScoreTile(
                          player: ranked[index],
                          rank: index + 1,
                          isWinner: index == 0,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _adShowing ? null : () {
                              game.resetGame();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CategorySelectionScreen()),
                                (route) => route.isFirst,
                              );
                            },
                            style: AppButtonStyles.primary,
                            child: Text(l10n.playAgain),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          child: Text(l10n.home,
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: isTablet ? 18.0 : 16.0)),
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
