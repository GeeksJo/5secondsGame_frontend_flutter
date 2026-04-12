import 'package:flutter/material.dart';
import 'package:yalla/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final steps = [
      (Icons.people, l10n.howToPlayStep1),
      (Icons.category, l10n.howToPlayStep2),
      (Icons.timer, l10n.howToPlayStep3),
      (Icons.touch_app, l10n.howToPlayStep4),
      (Icons.alarm_off, l10n.howToPlayStep5),
      (Icons.emoji_events, l10n.howToPlayStep6),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.howToPlay),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: ResponsiveLayout(
          maxWidth: 600,
          child: ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final (icon, text) = steps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: AppSpacing.cardPadding,
                  decoration: AppDecorations.card,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(icon, color: AppColors.textSecondary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
