import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/locale_provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_display.dart';
import '../widgets/responsive_layout.dart';
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
    final gifSize = isTablet ? 220.0 : 160.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: SafeArea(
          child: ResponsiveLayout(
            maxWidth: 600,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CoinDisplay(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.textSecondary),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                Text(
                  l10n.appName,
                  style: (isArabic
                          ? GoogleFonts.cairo(fontSize: titleSize, fontWeight: FontWeight.w900)
                          : GoogleFonts.poppins(fontSize: titleSize, fontWeight: FontWeight.w900))
                      .copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  l10n.appSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 20.0 : 16.0,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),

                const Spacer(flex: 2),

                Image.asset(
                  'assets/images/vote.gif',
                  width: gifSize,
                  height: gifSize,
                  fit: BoxFit.contain,
                ),

                const Spacer(flex: 2),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeButton(
                          context,
                          icon: Icons.people,
                          label: l10n.oneVsOne,
                          isTablet: isTablet,
                          onTap: () {
                            context.read<GameProvider>().setMode(GameMode.oneVsOne);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModeButton(
                          context,
                          icon: Icons.groups,
                          label: l10n.freeForAll,
                          isTablet: isTablet,
                          onTap: () {
                            context.read<GameProvider>().setMode(GameMode.freeForAll);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                  ),
                  child: Container(
                    width: isTablet ? 56.0 : 48.0,
                    height: isTablet ? 56.0 : 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardFill,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Icon(Icons.help_outline,
                          color: AppColors.textSecondary, size: isTablet ? 32.0 : 28.0),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 20),
        decoration: BoxDecoration(
          color: AppColors.cardFill,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: isTablet ? 40 : 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 20.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
