import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class SettingsDialogs {
  static TextDirection _dirFor(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  static Widget _wrapDir(BuildContext context, Widget child) {
    return Directionality(
      textDirection: _dirFor(context),
      child: child,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => _wrapDir(
        ctx,
        AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.correct, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialogOk),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showError(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => _wrapDir(
        ctx,
        AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.errorTitle,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialogOk),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> showConfirmRemoveAds(
    BuildContext context, {
    required String price,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _wrapDir(
        ctx,
        AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text(
            l10n.confirmRemoveAdsTitle,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            l10n.confirmRemoveAdsMessage(price),
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.dialogConfirm),
            ),
          ],
        ),
      ),
    );
    return ok ?? false;
  }
}
