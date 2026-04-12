import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'question_screen.dart';

class ReadyScreen extends StatefulWidget {
  const ReadyScreen({super.key});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  int _displayNumber = 5;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _countdownAnimation = Tween<double>(begin: 5.0, end: 0.0).animate(_countdownController);
    _countdownAnimation.addListener(_onCountdownTick);
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onCountdownComplete();
      }
    });

    // Auto-start the countdown immediately
    _countdownController.forward();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onCountdownTick() {
    final newNumber = _countdownAnimation.value.ceil();
    if (newNumber != _displayNumber && newNumber > 0) {
      setState(() => _displayNumber = newNumber);
      HapticFeedback.lightImpact();
      _playTick();
    }
  }

  void _playTick() {
    final soundEnabled = context.read<LocaleProvider>().soundEnabled;
    if (!soundEnabled) return;
    _audioPlayer.play(AssetSource('sounds/tick.wav')).catchError((_) {});
  }

  void _playGo() {
    final soundEnabled = context.read<LocaleProvider>().soundEnabled;
    if (!soundEnabled) return;
    _audioPlayer.play(AssetSource('sounds/go.wav')).catchError((_) {});
  }

  void _onCountdownComplete() {
    HapticFeedback.heavyImpact();
    _playGo();
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.round} ${game.currentRound}/${game.totalRounds}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: isTablet ? 20.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    game.currentPlayer.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 52.0 : 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildCountdown(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(bool isTablet) {
    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, _) {
        final value = _countdownAnimation.value;
        final number = value.ceil();
        if (number <= 0) {
          return const SizedBox.shrink();
        }

        final fraction = value - value.floor();

        return Column(
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey(number),
              tween: Tween(begin: 1.4, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: fraction.clamp(0.3, 1.0),
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: number <= 2 ? AppColors.danger : AppColors.coin,
                        fontSize: isTablet ? 100.0 : 80.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.getReady,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: isTablet ? 22.0 : 18.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
