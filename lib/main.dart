import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/questions.dart';
import 'providers/coin_provider.dart';
import 'providers/game_provider.dart';
import 'providers/locale_provider.dart';
import 'services/ad_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final adService = AdService();
  await adService.init();

  final questionBank = QuestionBank();
  await questionBank.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AdService>.value(value: adService),
        ChangeNotifierProvider(create: (_) => LocaleProvider(storage)),
        ChangeNotifierProvider(create: (_) => CoinProvider(storage, adService)),
        ChangeNotifierProvider(create: (_) => GameProvider(questionBank)),
      ],
      child: const YallaApp(),
    ),
  );
}
