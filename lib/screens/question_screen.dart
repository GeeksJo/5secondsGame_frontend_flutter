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
import '../services/game_kit_products.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/app_cross_promo.dart';
import '../widgets/red_button.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/settings/settings_dialogs.dart';
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

  double _timerDiameter(bool isTablet) => isTablet ? 128 : 112;

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

  Widget _buildIntroCountdownDisplay(double diameter, int introTotalBeats) {
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
      ),
    );
  }

  Widget _buildCountdownBlock(
    AppLocalizations l10n,
    bool isTablet,
    int introTotalBeats,
  ) {
    final d = _timerDiameter(isTablet);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_introComplete && _introBeat != null)
          _buildIntroCountdownDisplay(d, introTotalBeats)
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
                fontSize: isTablet ? 17 : 15,
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
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.pause_rounded,
              size: 26,
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
                fontSize: isTablet ? 17.0 : 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: GameKit.iap.adsRemoved,
            builder: (context, adsRemoved, _) {
              if (adsRemoved) {
                return const SizedBox(width: 48, height: 48);
              }
              return IconButton(
                tooltip: l10n.removeAds,
                onPressed: onRemoveAds,
                icon: Image.asset(
                  'assets/images/no_ads.png',
                  height: isTablet ? 50 : 40,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tappable row above the banner: opens cross-promo when [onOtherGames] is non-null.
  Widget _buildOtherGamesCta({
    required AppLocalizations l10n,
    required bool isTablet,
    required VoidCallback? onOtherGames,
  }) {
    final enabled = onOtherGames != null;
    final iconBg = AppColors.coin.withValues(alpha: enabled ? 0.22 : 0.1);
    final iconFg = enabled ? AppColors.coin : AppColors.textHint;
    final hPad = isTablet ? 22.0 : 18.0;
    final vPad = isTablet ? 13.0 : 11.0;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.cardFill,
          border: Border.all(
            color: enabled ? AppColors.cardBorder : AppColors.textDisabled,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: enabled ? 0.35 : 0.2),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          onTap: onOtherGames,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          splashColor: AppColors.primary.withValues(alpha: 0.2),
          highlightColor: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad * 0.55, vPad, hPad, vPad),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: isTablet ? 22 : 20,
                      color: iconFg,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 14 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.moreGames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontSize: isTablet ? 16.5 : 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.moreGamesSubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: enabled
                              ? AppColors.textMuted
                              : AppColors.textDisabled,
                          fontSize: isTablet ? 12.5 : 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final rtl = Directionality.of(context) == TextDirection.rtl;
                    return Icon(
                      rtl
                          ? Icons.chevron_right_rounded
                          : Icons.chevron_left_rounded,
                      size: isTablet ? 28 : 26,
                      color: enabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundLine(AppLocalizations l10n, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Center(
        child: Text(
          '${l10n.round} ${game.currentRound}/${game.totalRounds}',
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

  Widget _buildQuestionPanel({required bool isTablet, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              fontSize: isTablet ? 28.0 : 22.0,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainQuestionColumn({
    required AppLocalizations l10n,
    required GameProvider game,
    required bool isTablet,
    required bool is1v1,
    required int introTotalBeats,
    required VoidCallback? onPause,
    required VoidCallback? onRemoveAds,
    required VoidCallback? onOtherGames,
    required String headerName,
    required String questionText,
    required bool redEnabled,
    required VoidCallback onDone,
  }) {
    return Column(
      children: [
        _buildHeaderRow(
          l10n: l10n,
          isTablet: isTablet,
          centerName: headerName,
          onPause: onPause,
          onRemoveAds: onRemoveAds,
        ),
        _buildRoundLine(l10n, game),
        if (is1v1 && game.players.length == 2)
          _build1v1Scoreboard(game, isTablet)
        else
          const SizedBox(height: 6),
        const Spacer(flex: 2),
        _buildCountdownBlock(l10n, isTablet, introTotalBeats),
        SizedBox(height: isTablet ? 28 : 20),
        _buildQuestionPanel(isTablet: isTablet, text: questionText),
        const Spacer(flex: 3),
        RedButton(label: l10n.done, enabled: redEnabled, onPressed: onDone),
        const Spacer(flex: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 420 : 360),
              child: Tooltip(
                message: l10n.moreGames,
                child: Semantics(
                  button: true,
                  label: l10n.moreGames,
                  enabled: onOtherGames != null,
                  child: _buildOtherGamesCta(
                    l10n: l10n,
                    isTablet: isTablet,
                    onOtherGames: onOtherGames,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ValueListenableBuilder<bool>(
        //   valueListenable: GameKit.ads.bannersEnabled,
        //   builder: (context, enabled, _) {
        //     if (!enabled) return const SizedBox.shrink();
        //     return const GameKitBannerSlot();
        //   },
        // ),
        const SizedBox(height: 8),
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
    final ok = await SettingsDialogs.showConfirmRemoveAds(
      context,
      price: price,
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
      builder: (dialogContext) => Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppColors.textPrimary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.paused,
                    style: const TextStyle(
                      fontFamily: AppFonts.family,
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
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
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.family,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(l10n.resume),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await GameKitAdBridge.presentOnAbandonHome();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.family,
                          fontSize: 17,
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
      ),
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
    final levelForRating = game.currentRound;
    final isGameOver = game.answerCorrect();
    coinProvider.addCoins(1);
    GameKit.haptics.validAction();
    unawaited(GameKit.rating.levelSucceeded(level: levelForRating));

    _navigate(
      isGameOver,
      prevFlip: prevFlip,
      prevName: prevName,
      prevQuestionText: prevQuestionText,
    );
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

    _navigate(
      isGameOver,
      prevFlip: prevFlip,
      prevName: prevName,
      prevQuestionText: prevQuestionText,
    );
  }

  void _navigate(
    bool isGameOver, {
    required bool prevFlip,
    required String prevName,
    required String prevQuestionText,
  }) {
    if (!mounted) return;
    final game = context.read<GameProvider>();

    if (isGameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
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
      l10n: l10n,
      game: game,
      isTablet: isTablet,
      is1v1: is1v1,
      introTotalBeats: introTotalBeats,
      onPause: _turnFlipping || !_introComplete ? null : _showPauseMenu,
      onRemoveAds: _turnFlipping || !_introComplete || _answered || _paused
          ? null
          : _removeAdsFromHeader,
      onOtherGames: _turnFlipping || !_introComplete || _answered || _paused
          ? null
          : _openOtherGames,
      headerName: headerName,
      questionText: questionText,
      redEnabled: _introComplete,
      onDone: _onDonePressed,
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
              maxWidth: 600,
              child: AnimatedBuilder(
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
      l10n: l10n,
      game: game,
      isTablet: isTablet,
      is1v1: is1v1,
      introTotalBeats: introTotalBeats,
      onPause: null,
      onRemoveAds: null,
      onOtherGames: null,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                fontSize: isTablet ? 15.0 : 13.0,
                fontWeight: turn == 0 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${p1.score}  —  ${p2.score}',
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.textPrimary,
                fontSize: isTablet ? 18.0 : 16.0,
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
                fontSize: isTablet ? 15.0 : 13.0,
                fontWeight: turn == 1 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
