import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'ready_screen.dart';

class PassScreen extends StatefulWidget {
  const PassScreen({super.key});

  @override
  State<PassScreen> createState() => _PassScreenState();
}

class _PassScreenState extends State<PassScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final mode = context.read<GameProvider>().mode;
    if (mode == GameMode.oneVsOne) {
      _isFlipping = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _flipController.forward().then((_) {
            if (mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                _goToReady();
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _goToReady() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReadyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameProvider>();
    final mode = game.mode;
    final isTablet = ResponsiveLayout.isTablet(context);

    if (mode == GameMode.oneVsOne) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_flipController.value * math.pi),
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: AppDecorations.gradientBg,
              child: Center(
                child: _isFlipping
                    ? Icon(Icons.sync, color: AppColors.textSecondary,
                        size: isTablet ? 80 : 64)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GestureDetector(
          onTap: _goToReady,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppDecorations.gradientBg,
            child: SafeArea(
              child: ResponsiveLayout(
                maxWidth: 600,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_android, color: AppColors.textMuted,
                        size: isTablet ? 80 : 64),
                    const SizedBox(height: 24),
                    Text(
                      l10n.passTo,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: isTablet ? 22.0 : 18.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.currentPlayer.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTablet ? 44.0 : 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.tapToContinue,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: isTablet ? 18.0 : 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
