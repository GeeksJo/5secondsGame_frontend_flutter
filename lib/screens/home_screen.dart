import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/locale_provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'category_selection_screen.dart';
import 'settings_screen.dart';
import 'how_to_play_screen.dart';
import 'player_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = context.watch<LocaleProvider>().isArabic;
    final isTablet = ResponsiveLayout.isTablet(context);
    final titleSize = isTablet ? 80.0 : 64.0;
    final gifSize = isTablet ? 280.0 : 220.0;
    final modeButtonGap = isTablet ? 16.0 : 12.0;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: SafeArea(
          bottom: false,
          top: false,
          child: ResponsiveLayout(
            maxWidth: 600,
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -120,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -120,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SettingsTopChip(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),

                        Image.asset(
                          'assets/images/yalla.png',
                          width: gifSize,
                          height: gifSize,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 22),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: isRtl
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              isArabic ? 'اختر نمط اللعب' : 'Choose game mode',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 18 : 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: isTablet
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _ModeButton(
                                        icon: Icons.people,
                                        label: l10n.oneVsOne,
                                        subtitle: isArabic
                                            ? 'شخصين • قلب الشاشة'
                                            : '2 players • screen flip',
                                        isPrimary: true,
                                        isRtl: isRtl,
                                        onTap: () {
                                          context.read<GameProvider>().setMode(
                                            GameMode.oneVsOne,
                                          );
                                          context
                                              .read<GameProvider>()
                                              .setPlayers(
                                                isArabic
                                                    ? const ['لاعب ١', 'لاعب ٢']
                                                    : const [
                                                        'Player 1',
                                                        'Player 2',
                                                      ],
                                              );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CategorySelectionScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: modeButtonGap),
                                    Expanded(
                                      child: _ModeButton(
                                        icon: Icons.groups,
                                        label: l10n.freeForAll,
                                        subtitle: isArabic
                                            ? '٣+ لاعبين • مرّر الهاتف'
                                            : '3+ players • pass phone',
                                        isPrimary: false,
                                        isRtl: isRtl,
                                        onTap: () {
                                          context.read<GameProvider>().setMode(
                                            GameMode.freeForAll,
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PlayerSetupScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _ModeButton(
                                      icon: Icons.people,
                                      label: l10n.oneVsOne,
                                      subtitle: isArabic
                                          ? 'شخصين • قلب الشاشة'
                                          : '2 players • screen flip',
                                      isPrimary: true,
                                      isRtl: isRtl,
                                      onTap: () {
                                        context.read<GameProvider>().setMode(
                                          GameMode.oneVsOne,
                                        );
                                        context.read<GameProvider>().setPlayers(
                                          isArabic
                                              ? const ['لاعب ١', 'لاعب ٢']
                                              : const ['Player 1', 'Player 2'],
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CategorySelectionScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: modeButtonGap),
                                    _ModeButton(
                                      icon: Icons.groups,
                                      label: l10n.freeForAll,
                                      subtitle: isArabic
                                          ? '٣+ لاعبين • مرّر الهاتف'
                                          : '3+ players • pass phone',
                                      isPrimary: false,
                                      isRtl: isRtl,
                                      onTap: () {
                                        context.read<GameProvider>().setMode(
                                          GameMode.freeForAll,
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PlayerSetupScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 14),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HowToPlayScreen(),
                            ),
                          ),
                          icon: const Icon(
                            Icons.help_outline,
                            color: AppColors.textSecondary,
                          ),
                          label: Text(
                            isArabic ? 'طريقة اللعب' : 'How to play',
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTopChip extends StatefulWidget {
  final VoidCallback onTap;

  const _SettingsTopChip({required this.onTap});

  @override
  State<_SettingsTopChip> createState() => _SettingsTopChipState();
}

class _SettingsTopChipState extends State<_SettingsTopChip> {
  late bool _badge;
  StreamSubscription<bool>? _crossPromoSub;

  @override
  void initState() {
    super.initState();
    _badge = GameKit.crossPromo.hasNewGame;
    _crossPromoSub = GameKit.crossPromo.hasNewGameChanges.listen((show) {
      if (mounted) setState(() => _badge = show);
    });
  }

  @override
  void dispose() {
    unawaited(_crossPromoSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: widget.onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
        if (_badge)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final bool isRtl;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    const navy = Color(0xFF0C2A77);
    const coral = Color(0xFFFF5E57);
    const magenta = Color(0xFFB0387A);
    const ice = Color(0xFFD9E3FF);
    const ice2 = Color(0xFFC9D7FF);
    const arrowYellow = Color(0xFFF7C64A);

    final fg = navy;
    final sub = navy.withValues(alpha: 0.70);
    final pillBorder = navy.withValues(alpha: 0.18);
    final chevronIcon = isRtl
        ? Icons.chevron_right_rounded
        : Icons.chevron_left_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      splashColor: Colors.white.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 20 : 18,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPrimary
                ? [ice.withValues(alpha: 0.96), ice2.withValues(alpha: 0.90)]
                : [ice.withValues(alpha: 0.82), ice2.withValues(alpha: 0.74)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: pillBorder),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            if (isPrimary)
              BoxShadow(
                color: arrowYellow.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 0),
              ),
            if (!isPrimary)
              BoxShadow(
                color: magenta.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border(
            bottom: BorderSide(color: isPrimary ? coral : magenta, width: 3),
          ),
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: isTablet ? 52 : 46,
              height: isTablet ? 52 : 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: navy.withValues(alpha: 0.20)),
              ),
              child: Icon(icon, color: fg, size: isTablet ? 30 : 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      color: fg,
                      fontSize: isTablet ? 20 : 16.5,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      color: sub,
                      fontSize: isTablet ? 14 : 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: isTablet ? 42 : 38,
              height: isTablet ? 42 : 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.round),
                border: Border.all(color: navy.withValues(alpha: 0.18)),
              ),
              child: Icon(
                chevronIcon,
                size: isTablet ? 26 : 24,
                color: fg.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
