import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

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
          maxWidth: 500,
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                _buildTile(
                  icon: Icons.language,
                  title: l10n.language,
                  trailing: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                    ],
                    selected: {localeProvider.locale.languageCode},
                    onSelectionChanged: (selected) {
                      localeProvider.setLocale(Locale(selected.first));
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.cardBorder;
                        }
                        return Colors.transparent;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTile(
                  icon: localeProvider.soundEnabled
                      ? Icons.volume_up
                      : Icons.volume_off,
                  title: l10n.sound,
                  trailing: Switch(
                    value: localeProvider.soundEnabled,
                    onChanged: (_) => localeProvider.toggleSound(),
                    activeTrackColor: AppColors.textHint,
                    activeThumbColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
