import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storage;
  late Locale _locale;
  late bool _soundEnabled;

  LocaleProvider(this._storage) {
    _locale = Locale(_storage.getLocale());
    _soundEnabled = _storage.getSoundEnabled();
  }

  Locale get locale => _locale;
  bool get soundEnabled => _soundEnabled;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _storage.setLocale(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _storage.setSoundEnabled(_soundEnabled);
    notifyListeners();
  }
}
