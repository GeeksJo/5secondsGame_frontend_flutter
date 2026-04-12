import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class YallaApp extends StatelessWidget {
  const YallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Yalla',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(localeProvider.isArabic),
      home: const HomeScreen(),
    );
  }
}
