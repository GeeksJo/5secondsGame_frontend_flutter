import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:provider/provider.dart';
import 'package:yalla/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const double _sectionSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final palette = GameKit.settingsUi != null
        ? GameKitSettingsPalette.fromUiConfig(GameKit.settingsUi!)
        : GameKitSettingsPalette.fromSeed(
            AppColors.primary,
            fontFamily: AppFonts.family,
            sectionCardAppearance: GameKitSectionCardAppearance.frosted,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: ResponsiveLayout(
          maxWidth: 520,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              GameKitSettingSectionWidget(
                palette: palette,
                margin: EdgeInsets.zero,
                headerIcon: Icons.apps_rounded,
                headerTitle: l10n.sectionAppInfo,
                fontFamily: AppFonts.family,
                child: GameKitSettingItem(
                  palette: palette,
                  fontFamily: AppFonts.family,
                  icon: Icons.celebration_outlined,
                  title: l10n.appName,
                  subtitle: l10n.appInfoLine,
                  showDivider: false,
                ),
              ),
              SizedBox(height: _sectionSpacing),
              GameKitSettingSectionWidget(
                palette: palette,
                margin: EdgeInsets.zero,
                fontFamily: AppFonts.family,
                child: _soundTile(context, localeProvider, palette),
              ),
              SizedBox(height: _sectionSpacing),
              const GameKitSettingsBody(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                sectionSpacing: _sectionSpacing,
                maxWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soundTile(
    BuildContext context,
    LocaleProvider localeProvider,
    GameKitSettingsPalette palette,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GameKitSettingItem(
      palette: palette,
      fontFamily: AppFonts.family,
      icon: localeProvider.soundEnabled ? Icons.volume_up : Icons.volume_off,
      title: l10n.sound,
      showDivider: false,
      trailing: Switch(
        value: localeProvider.soundEnabled,
        onChanged: (_) => localeProvider.toggleSound(),
        activeTrackColor: AppColors.textHint,
        activeThumbColor: AppColors.textPrimary,
      ),
    );
  }
}
