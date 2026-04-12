import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryDeep = Color(0xFF1A237E);
  static const surface = Color(0xFF1E1E2E);
  static const coin = Colors.amber;
  static const correct = Colors.green;
  static const danger = Colors.red;

  static const cardFill = Colors.white10;
  static const cardBorder = Colors.white24;
  static const cardFillDark = Colors.black87;

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const textMuted = Colors.white60;
  static const textHint = Colors.white38;
  static const textDisabled = Colors.white24;
}

abstract class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const dark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryDark, AppColors.primaryDeep],
  );
}

abstract class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 26.0;
  static const round = 28.0;
}

abstract class AppSpacing {
  static const screenPadding = EdgeInsets.all(24.0);
  static const screenH = EdgeInsets.symmetric(horizontal: 24.0);
  static const cardPadding = EdgeInsets.all(16.0);
  static const buttonHeight = 52.0;
  static const buttonHeightLg = 56.0;
}

abstract class AppDecorations {
  static const gradientBg = BoxDecoration(gradient: AppGradients.primary);
  static const darkGradientBg = BoxDecoration(gradient: AppGradients.dark);

  static final card = BoxDecoration(
    color: AppColors.cardFill,
    borderRadius: BorderRadius.circular(AppRadius.lg),
  );

  static final cardWithBorder = BoxDecoration(
    color: AppColors.cardFill,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: AppColors.cardBorder),
  );

  static final bottomSheet = BoxDecoration(
    color: AppColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  );
}

abstract class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  static ButtonStyle primaryDisabled = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primary,
    disabledBackgroundColor: AppColors.textDisabled,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}

ThemeData buildAppTheme(bool isArabic) {
  final baseTextTheme = ThemeData.dark().textTheme;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: isArabic
        ? GoogleFonts.cairoTextTheme(baseTextTheme)
        : GoogleFonts.poppinsTextTheme(baseTextTheme),
    useMaterial3: true,
  );
}
