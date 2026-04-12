import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/coin_provider.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/red_button.dart';
import '../widgets/responsive_layout.dart';
import 'home_screen.dart';
import 'pass_screen.dart';
import 'scoreboard_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _flipController;
  late Widget _bannerWidget;
  bool _answered = false;
  bool _paused = false;
  bool _flipping = false;

  @override
  void initState() {
    super.initState();
    _bannerWidget = context.read<AdService>().getBannerWidget();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _timerController.forward();
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_answered) {
        _onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _togglePause() {
    if (_answered) return;
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _timerController.stop();
      } else {
        _timerController.forward();
      }
    });
  }

  void _showPauseMenu() {
    _togglePause();
    final l10n = AppLocalizations.of(context)!;
    final adService = context.read<AdService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.paused,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _togglePause();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    l10n.resume,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await adService.showInterstitial();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    l10n.home,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDonePressed() {
    if (_answered || _paused) return;
    _answered = true;
    _timerController.stop();

    final game = context.read<GameProvider>();
    final coinProvider = context.read<CoinProvider>();
    final isGameOver = game.answerCorrect();
    coinProvider.addCoins(1);

    _navigate(isGameOver);
  }

  void _onTimeout() {
    if (_answered) return;
    _answered = true;
    HapticFeedback.heavyImpact();

    final game = context.read<GameProvider>();
    final isGameOver = game.answerTimeout();

    _navigate(isGameOver);
  }

  void _navigate(bool isGameOver) {
    if (!mounted) return;
    final game = context.read<GameProvider>();

    if (isGameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
      );
    } else if (game.mode == GameMode.oneVsOne) {
      _playFlipTransition();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PassScreen()),
      );
    }
  }

  void _playFlipTransition() {
    HapticFeedback.mediumImpact();
    setState(() => _flipping = true);
    _flipController.forward().then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const QuestionScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final question = game.currentQuestion;
    final isTablet = ResponsiveLayout.isTablet(context);
    final is1v1 = game.mode == GameMode.oneVsOne;

    Widget body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.pause, color: AppColors.textSecondary, size: 28),
                onPressed: _showPauseMenu,
              ),
              Text(
                game.currentPlayer.name,
                style: TextStyle(
                  color: AppColors.coin,
                  fontSize: isTablet ? 22.0 : 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        if (is1v1 && game.players.length == 2)
          _build1v1Scoreboard(game, isTablet),

        const Spacer(flex: 2),
        AnimatedBuilder(
          animation: _timerController,
          builder: (context, _) {
            final remaining = 5 - (_timerController.value * 5);
            return CountdownTimer(
              progress: 1 - _timerController.value,
              secondsLeft: remaining.ceil(),
            );
          },
        ),
        SizedBox(height: isTablet ? 40 : 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            question?.text(locale) ?? '',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTablet ? 36.0 : 30.0,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(flex: 3),
        RedButton(
          label: l10n.done,
          onPressed: _onDonePressed,
        ),
        const Spacer(flex: 1),
        _bannerWidget,
        const SizedBox(height: 8),
      ],
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppDecorations.darkGradientBg,
          child: SafeArea(
            child: ResponsiveLayout(
              maxWidth: 600,
              child: _flipping
                  ? AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_flipController.value * math.pi),
                          child: Opacity(
                            opacity: (1 - _flipController.value).clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: body,
                    )
                  : body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _build1v1Scoreboard(GameProvider game, bool isTablet) {
    final p1 = game.players[0];
    final p2 = game.players[1];

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            p1.name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTablet ? 18.0 : 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${p1.score}  -  ${p2.score}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 26.0 : 22.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          Text(
            p2.name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTablet ? 18.0 : 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
