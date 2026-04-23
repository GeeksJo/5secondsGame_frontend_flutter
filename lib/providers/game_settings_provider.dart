import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class GameSettingsProvider extends ChangeNotifier {
  GameSettingsProvider(this._storage) {
    _questionTimerSeconds = _storage.getQuestionTimerSeconds();
  }

  final StorageService _storage;

  static const int minQuestionTimerSeconds = 3;
  static const int maxQuestionTimerSeconds = 60;
  static const int defaultQuestionTimerSeconds = 5;

  late int _questionTimerSeconds;

  int get questionTimerSeconds => _questionTimerSeconds;

  Future<void> setQuestionTimerSeconds(int value) async {
    final clamped = value.clamp(
      minQuestionTimerSeconds,
      maxQuestionTimerSeconds,
    );
    if (clamped == _questionTimerSeconds) return;
    _questionTimerSeconds = clamped;
    notifyListeners();
    await _storage.setQuestionTimerSeconds(clamped);
  }
}
