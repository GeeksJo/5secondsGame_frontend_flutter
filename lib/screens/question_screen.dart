import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:game_kit/game_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/coin_provider.dart';
import '../providers/game_provider.dart';
import '../providers/game_settings_provider.dart';
import '../providers/locale_provider.dart';
import '../services/game_kit_bootstrap.dart';
import '../services/storage_service.dart';
import '../services/game_kit_products.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/app_cross_promo.dart';
import '../widgets/game_kit_banner_slot.dart';
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
  late AnimationController _turnFlipController;
  bool _answered = false;
  bool _paused = false;
  bool _turnFlipping = false;
  bool _flipFrom = false;
  bool _flipTo = false;
  String? _flipName;
  String? _flipQuestionText;
  late int _answerSeconds;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _introComplete = false;
  int? _introBeat;

  static const _introTickGap = Duration(milliseconds: 420);
  static const _afterLastIntroTick = Duration(milliseconds: 160);

  double _timerDiameter(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final wide = ResponsiveLayout.useWideGameLayout(context);
    final compact = ResponsiveLayout.isCompactHeight(context);
    if (wide && compact) {
      return isTablet ? 120 : 92;
    }
    if (isTablet && ResponsiveLayout.isLandscape(context)) {
      return compact ? 128 : 154;
    }
    if (isTablet) return 162;
    return 112;
  }

  @override
  void initState() {
    super.initState();
    _answerSeconds = context.read<GameSettingsProvider>().questionTimerSeconds;
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _answerSeconds),
    );
    _turnFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_answered) {
        _onTimeout();
      }
    });
    final isFFA = context.read<GameProvider>().mode == GameMode.freeForAll;
    if (isFFA) {
      _introComplete = true;
      _introBeat = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(GameKit.notifications.markPlayedToday());
      if (context.read<GameProvider>().mode == GameMode.freeForAll) {
        unawaited(_ffaStartAnswerPhase());
      } else {
        _startAnswerTimerAfterIntroTicks();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _turnFlipController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _introHaptic(int index) {
    if (index == 0) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _playGoSound() async {
    final soundEnabled = context.read<LocaleProvider>().soundEnabled;
    if (!soundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/go.wav'));
  }

  Future<void> _ffaStartAnswerPhase() async {
    if (!mounted || _answered) return;
    await _playGoSound();
    if (!mounted || _answered) return;
    HapticFeedback.mediumImpact();
    _timerController.forward(from: 0);
  }

  Future<void> _startAnswerTimerAfterIntroTicks() async {
    if (!mounted || _answered) return;
    const introBeats = 2;
    setState(() {
      _introComplete = false;
      _introBeat = introBeats;
    });
    final soundEnabled = context.read<LocaleProvider>().soundEnabled;
    for (var i = 0; i < introBeats; i++) {
      if (!mounted || _answered) return;
      final beat = introBeats - i;
      setState(() => _introBeat = beat);
      if (soundEnabled) {
        await _audioPlayer.play(AssetSource('sounds/tick.wav'));
      }
      _introHaptic(i);
      if (i < introBeats - 1) {
        await Future<void>.delayed(_introTickGap);
      }
    }
    if (!mounted || _answered) return;
    await Future<void>.delayed(_afterLastIntroTick);
    if (!mounted || _answered) return;
    await _playGoSound();
    if (!mounted || _answered) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _introBeat = null;
      _introComplete = true;
    });
    _timerController.forward(from: 0);
  }

  Widget _buildIntroCountdownDisplay(
    double diameter,
    int introTotalBeats, {
    double? introRingStrokeWidth,
  }) {
    final beat = _introBeat!;
    final progress = (introTotalBeats + 1 - beat) / introTotalBeats.toDouble();
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(beat),
      tween: Tween(begin: 1.08, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: CountdownTimer(
        progress: progress,
        secondsLeft: beat,
        isIntro: true,
        diameter: diameter,
        introRingStrokeWidth: introRingStrokeWidth,
      ),
    );
  }

  Widget _buildCountdownBlock(
    AppLocalizations l10n,
    bool isTablet,
    int introTotalBeats,
    double timerDiameter,
  ) {
    final d = timerDiameter;
    final introStroke = isTablet ? 12.0 : null;
    final answerStroke = isTablet ? 14.0 : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_introComplete && _introBeat != null)
          _buildIntroCountdownDisplay(
            d,
            introTotalBeats,
            introRingStrokeWidth: introStroke,
          )
        else
          AnimatedBuilder(
            animation: _timerController,
            builder: (context, _) {
              final remaining =
                  _answerSeconds - (_timerController.value * _answerSeconds);
              return CountdownTimer(
                progress: (1 - _timerController.value).clamp(0.0, 1.0),
                secondsLeft: remaining.ceil(),
                diameter: d,
                answerRingStrokeWidth: answerStroke,
              );
            },
          ),
        if (!_introComplete && _introBeat != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l10n.getReady,
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.textMuted,
                fontSize: isTablet ? 26 : 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderRow({
    required AppLocalizations l10n,
    required bool isTablet,
    required String centerName,
    required VoidCallback? onPause,
    required VoidCallback? onRemoveAds,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, isTablet ? 8 : 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              minimumSize: Size(isTablet ? 64 : 48, isTablet ? 64 : 48),
            ),
            icon: Icon(
              Icons.pause_rounded,
              size: isTablet ? 80 : 26,
              color: onPause == null
                  ? AppColors.textHint
                  : AppColors.textSecondary,
            ),
            onPressed: onPause,
          ),
          Expanded(
            child: Text(
              centerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.coin,
                fontSize: isTablet ? 50.0 : 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: GameKit.iap.adsRemoved,
            builder: (context, adsRemoved, _) {
              final w = isTablet ? 72.0 : 48.0;
              if (adsRemoved) {
                return SizedBox(width: w, height: w);
              }
              return IconButton(
                style: IconButton.styleFrom(minimumSize: Size(w, w)),
                tooltip: l10n.removeAds,
                onPressed: onRemoveAds,
                icon: Image.asset(
                  'assets/images/no_ads.png',
                  height: isTablet ? 100 : 40,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoundLine(
    AppLocalizations l10n,
    GameProvider game,
    bool isTablet,
  ) {
    final text = '${l10n.round} ${game.currentRound}/${game.totalRounds}';
    if (!isTablet) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textMuted,
              fontSize: 35,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPanel({required bool isTablet, required String text}) {
    final fontSize = isTablet ? 38.0 : 22.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: _introComplete ? 1 : 0.48,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            text,
            key: ValueKey<String>(text),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlot() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ValueListenableBuilder<bool>(
          valueListenable: GameKit.ads.bannersEnabled,
          builder: (context, enabled, _) {
            if (!enabled) return const SizedBox.shrink();
            return const GameKitBannerSlot();
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMainQuestionColumn({
    required BuildContext context,
    required AppLocalizations l10n,
    required GameProvider game,
    required bool isTablet,
    required bool is1v1,
    required int introTotalBeats,
    required VoidCallback? onPause,
    required VoidCallback? onRemoveAds,
    required String headerName,
    required String questionText,
    required bool redEnabled,
    required VoidCallback onDone,
  }) {
    final timerD = _timerDiameter(context);
    final redBase = ResponsiveLayout.redButtonDiameter(context);
    final redD = isTablet ? redBase + 36.0 : redBase;

    return Column(
      children: [
        _buildHeaderRow(
          l10n: l10n,
          isTablet: isTablet,
          centerName: headerName,
          onPause: onPause,
          onRemoveAds: onRemoveAds,
        ),
        _buildRoundLine(l10n, game, isTablet),
        if (is1v1 && game.players.length == 2)
          _build1v1Scoreboard(game, isTablet)
        else
          const SizedBox(height: 6),
        const Spacer(flex: 2),
        _buildCountdownBlock(l10n, isTablet, introTotalBeats, timerD),
        SizedBox(height: isTablet ? 28 : 20),
        _buildQuestionPanel(isTablet: isTablet, text: questionText),
        const Spacer(flex: 3),
        RedButton(
          label: l10n.done,
          enabled: redEnabled,
          onPressed: onDone,
          diameter: redD,
        ),
        const Spacer(flex: 1),
        _buildBannerSlot(),
      ],
    );
  }

  void _openOtherGames() {
    if (_answered || _paused || _turnFlipping || !_introComplete) return;
    HapticFeedback.lightImpact();
    unawaited(showAppCrossPromoSheet(context));
  }

  Future<void> _removeAdsFromHeader() async {
    if (_answered || _paused || _turnFlipping || !_introComplete) return;
    if (GameKit.iap.adsRemoved.value) return;
    HapticFeedback.lightImpact();

    final l10n = AppLocalizations.of(context)!;
    final price = GameKit.iap.getFormattedPrice(GameKitProducts.removeAds);
    final ui = GameKit.settingsUi;
    final dialogColors = GameKitSettingsDialogColors.fromConfig(
      seedColor: ui?.seedColor ?? AppColors.primary,
      dialog: ui?.dialog,
    );
    final ok = await GameKitSettingsDialogs.showConfirmRemoveAds(
      context,
      dialogColors: dialogColors,
      locale: GameKit.locale,
      price: price,
      fontFamily: ui?.fontFamily,
    );
    if (!ok || !mounted) return;
    await GameKit.iap.purchaseRemoveAds();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.purchaseThanks)));
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

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        final isPad = ResponsiveLayout.isTablet(dialogContext);
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: isPad ? 40 : 24),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isPad ? 440 : 360),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPad ? 32 : 24,
                  vertical: isPad ? 32 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isPad ? 72.0 : 58,
                      height: isPad ? 72.0 : 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause_rounded,
                        color: AppColors.textPrimary,
                        size: isPad ? 42 : 34,
                      ),
                    ),
                    SizedBox(height: isPad ? 18 : 14),
                    Text(
                      l10n.paused,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        color: AppColors.textPrimary,
                        fontSize: isPad ? 42 : 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: isPad ? 24 : 20),
                    SizedBox(
                      width: double.infinity,
                      height: isPad ? 62.0 : 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _togglePause();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          textStyle: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: isPad ? 22 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(l10n.resume),
                      ),
                    ),
                    SizedBox(height: isPad ? 14 : 10),
                    SizedBox(
                      width: double.infinity,
                      height: isPad ? 62.0 : 54,
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await GameKitAdBridge.presentOnAbandonHome();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          textStyle: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: isPad ? 21 : 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          l10n.home,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
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

  void _onDonePressed() {
    if (_answered || _paused || _turnFlipping || !_introComplete) return;
    _answered = true;
    _timerController.stop();

    final game = context.read<GameProvider>();
    final locale = context.read<LocaleProvider>().locale.languageCode;
    final prevName = game.currentPlayer.name;
    final prevQuestionText = game.currentQuestion?.text(locale) ?? '';
    final prevFlip = game.isFlipped;
    final coinProvider = context.read<CoinProvider>();
    final isGameOver = game.answerCorrect();
    coinProvider.addCoins(1);
    GameKit.haptics.validAction();
    unawaited(_notifyRatingAfterCorrectAnswer());

    _navigate(
      isGameOver,
      prevFlip: prevFlip,
      prevName: prevName,
      prevQuestionText: prevQuestionText,
    );
  }

  Future<void> _notifyRatingAfterCorrectAnswer() async {
    final storage = context.read<StorageService>();
    final level = await storage.incrementRatingSuccessCount();
    if (!mounted) return;
    await GameKit.rating.levelSucceeded(level: level);
  }

  void _onTimeout() {
    if (_answered || _turnFlipping) return;
    _answered = true;
    HapticFeedback.heavyImpact();

    final game = context.read<GameProvider>();
    final locale = context.read<LocaleProvider>().locale.languageCode;
    final prevName = game.currentPlayer.name;
    final prevQuestionText = game.currentQuestion?.text(locale) ?? '';
    final prevFlip = game.isFlipped;
    final isGameOver = game.answerTimeout();

    unawaited(GameKit.rating.levelFailed());

    _navigate(
      isGameOver,
      prevFlip: prevFlip,
      prevName: prevName,
      prevQuestionText: prevQuestionText,
      roundFailed: true,
    );
  }

  void _navigate(
    bool isGameOver, {
    required bool prevFlip,
    required String prevName,
    required String prevQuestionText,
    bool roundFailed = false,
  }) {
    if (!mounted) return;
    final game = context.read<GameProvider>();

    if (isGameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreboardScreen(adsRoundFailed: roundFailed),
        ),
      );
    } else if (game.mode == GameMode.oneVsOne) {
      _playTurnFlip(
        prevFlip: prevFlip,
        nextFlip: game.isFlipped,
        prevName: prevName,
        prevQuestionText: prevQuestionText,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PassScreen()),
      );
    }
  }

  void _playTurnFlip({
    required bool prevFlip,
    required bool nextFlip,
    required String prevName,
    required String prevQuestionText,
  }) {
    if (_turnFlipping) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _turnFlipping = true;
      _flipFrom = prevFlip;
      _flipTo = nextFlip;
      _flipName = prevName;
      _flipQuestionText = prevQuestionText;
    });
    _turnFlipController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _turnFlipping = false;
        _flipName = null;
        _flipQuestionText = null;
      });
      _answered = false;
      _paused = false;
      _startAnswerTimerAfterIntroTicks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();

    if (game.players.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      });
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppDecorations.gradientBg,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final question = game.currentQuestion;
    final isTablet = ResponsiveLayout.isTablet(context);
    final is1v1 = game.mode == GameMode.oneVsOne;
    const introTotalBeats = 2;

    final headerName = _turnFlipping
        ? (_flipName ?? '')
        : game.currentPlayer.name;
    final questionText = _turnFlipping
        ? (_flipQuestionText ?? '')
        : (question?.text(locale) ?? '');

    final body = _buildMainQuestionColumn(
      context: context,
      l10n: l10n,
      game: game,
      isTablet: isTablet,
      is1v1: is1v1,
      introTotalBeats: introTotalBeats,
      onPause: _turnFlipping || !_introComplete ? null : _showPauseMenu,
      onRemoveAds: _turnFlipping || !_introComplete || _answered || _paused
          ? null
          : _removeAdsFromHeader,
      headerName: headerName,
      questionText: questionText,
      redEnabled: _introComplete,
      onDone: _onDonePressed,
    );

    final questionContentMaxWidth = isTablet
        ? double.infinity
        : ResponsiveLayout.maxWidthFor(
            context,
            phone: 600,
            tabletPortrait: 780,
            tabletLandscape: 960,
          );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppDecorations.gradientBg,
          child: SafeArea(
            bottom: false,
            child: ResponsiveLayout(
              maxWidth: questionContentMaxWidth,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _turnFlipController,
                    builder: (context, child) {
                      final baseFrom = _flipFrom ? math.pi : 0.0;
                      final baseTo = _flipTo ? math.pi : 0.0;
                      final t = _turnFlipping
                          ? Curves.easeInOutCubic.transform(
                              _turnFlipController.value,
                            )
                          : 1.0;
                      final angle = _turnFlipping
                          ? baseFrom + (baseTo - baseFrom) * t
                          : (game.isFlipped ? math.pi : 0.0);
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateZ(angle),
                        child: _turnFlipping && _turnFlipController.value >= 0.5
                            ? _buildLiveBody(context)
                            : child,
                      );
                    },
                    child: body,
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _turnFlipping ? null : _openOtherGames,
                          borderRadius: BorderRadius.circular(
                            AppRadius.round(context),
                          ),
                          child: Ink(
                            width: isTablet ? 100 : 44,
                            height: isTablet ? 100 : 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFF52E3D7,
                                  ).withValues(alpha: 0.95),
                                  const Color(
                                    0xFF23BEB4,
                                  ).withValues(alpha: 0.95),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.round(context),
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Transform.rotate(
                              angle: 0.78539816339, // 45°
                              child: Center(
                                child: Transform.rotate(
                                  angle: -0.78539816339,
                                  child: Image.asset(
                                    'assets/images/game_controller.png',
                                    width: isTablet ? 80 : 24,
                                    height: isTablet ? 80 : 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildLiveBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final question = game.currentQuestion;
    final isTablet = ResponsiveLayout.isTablet(context);
    final is1v1 = game.mode == GameMode.oneVsOne;
    const introTotalBeats = 2;

    return _buildMainQuestionColumn(
      context: context,
      l10n: l10n,
      game: game,
      isTablet: isTablet,
      is1v1: is1v1,
      introTotalBeats: introTotalBeats,
      onPause: null,
      onRemoveAds: null,
      headerName: game.currentPlayer.name,
      questionText: question?.text(locale) ?? '',
      redEnabled: _introComplete,
      onDone: () {},
    );
  }

  Widget _build1v1Scoreboard(GameProvider game, bool isTablet) {
    final p1 = game.players[0];
    final p2 = game.players[1];
    final turn = game.currentPlayerIndex;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16,
        8,
        isTablet ? 20 : 16,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p1.name,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: turn == 0
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: isTablet ? 30.0 : 13.0,
                fontWeight: turn == 0 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 10),
            child: Text(
              '${p1.score}  —  ${p2.score}',
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.textPrimary,
                fontSize: isTablet ? 40.0 : 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              p2.name,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: turn == 1
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: isTablet ? 30.0 : 13.0,
                fontWeight: turn == 1 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
