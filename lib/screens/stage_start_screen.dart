import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'question_screen.dart';

/// Full-screen countdown after categories + Start (same layout for 1v1 and FFA;
/// FFA uses 3s / 3–2–1, 1v1 uses 2s / 2–1; tick audio only in 1v1).
/// Mid-game FFA: [PassScreen] → [QuestionScreen] directly.
class StageStartScreen extends StatefulWidget {
  const StageStartScreen({super.key});

  @override
  State<StageStartScreen> createState() => _StageStartScreenState();
}

class _StageStartScreenState extends State<StageStartScreen>
    with SingleTickerProviderStateMixin {
  late final bool _ffa;
  late final int _countFrom;
  late final AnimationController _controller;
  final AudioPlayer _audio = AudioPlayer();
  late int _displayNumber;

  @override
  void initState() {
    super.initState();
    _ffa = context.read<GameProvider>().mode == GameMode.freeForAll;
    _countFrom = _ffa ? 3 : 2;
    _displayNumber = _countFrom;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _countFrom),
    );
    _controller.addListener(_onTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onComplete();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _playTickIfSound();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _onTick() {
    final v = _controller.value;
    final n = (_countFrom - (v * _countFrom).floor()).clamp(1, _countFrom);
    if (n != _displayNumber) {
      setState(() => _displayNumber = n);
      HapticFeedback.lightImpact();
      _playTickIfSound();
    }
  }

  void _playTickIfSound() {
    if (_ffa) return;
    final sound = context.read<LocaleProvider>().soundEnabled;
    if (!sound) return;
    _audio.play(AssetSource('sounds/tick.wav')).catchError((_) {});
  }

  void _onComplete() {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();
    final isTablet = ResponsiveLayout.isTablet(context);
    final titleSize = isTablet ? 40.0 : 28.0;
    final digitSize = isTablet ? 96.0 : 78.0;
    final ring = isTablet ? 152.0 : 128.0;

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
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(game.isFlipped ? math.pi : 0.0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(height: isTablet ? 36 : 24),
                          Text(
                            l10n.stageStartsIn,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryDeep
                                      .withValues(alpha: 0.95),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                ),
                                Shadow(
                                  color: AppColors.danger
                                      .withValues(alpha: 0.88),
                                  offset: const Offset(0, 5),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.45),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                          SizedBox(
                            width: ring,
                            height: ring,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: ring,
                                  height: ring,
                                  child: CircularProgressIndicator(
                                    value: _controller.value.clamp(0.0, 1.0),
                                    strokeWidth: 7,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: AppColors.cardBorder,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.coin,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$_displayNumber',
                                  style: TextStyle(
                                    fontFamily: AppFonts.family,
                                    color: AppColors.textPrimary,
                                    fontSize: digitSize,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primaryDeep
                                            .withValues(alpha: 0.55),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 3),
                          Text(
                            l10n.stageStartsFootnote,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: isTablet ? 28 : 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
