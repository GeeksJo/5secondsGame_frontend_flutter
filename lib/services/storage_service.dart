import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _coinsKey = 'coins';
  static const _purchasedKey = 'purchased_categories';
  static const _rentedPrefix = 'rented_';
  static const _localeKey = 'locale';
  static const _soundKey = 'sound_enabled';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int getCoins() => _prefs.getInt(_coinsKey) ?? 50;

  Future<void> setCoins(int coins) => _prefs.setInt(_coinsKey, coins);

  List<String> getPurchasedCategories() =>
      _prefs.getStringList(_purchasedKey) ?? [];

  Future<void> setPurchasedCategories(List<String> categories) =>
      _prefs.setStringList(_purchasedKey, categories);

  DateTime? getRentedExpiry(String categoryKey) {
    final ms = _prefs.getInt('$_rentedPrefix$categoryKey');
    if (ms == null) return null;
    final expiry = DateTime.fromMillisecondsSinceEpoch(ms);
    if (expiry.isBefore(DateTime.now())) {
      _prefs.remove('$_rentedPrefix$categoryKey');
      return null;
    }
    return expiry;
  }

  Future<void> setRentedExpiry(String categoryKey, DateTime expiry) =>
      _prefs.setInt('$_rentedPrefix$categoryKey', expiry.millisecondsSinceEpoch);

  String getLocale() => _prefs.getString(_localeKey) ?? 'ar';

  Future<void> setLocale(String locale) => _prefs.setString(_localeKey, locale);

  bool getSoundEnabled() => _prefs.getBool(_soundKey) ?? true;

  Future<void> setSoundEnabled(bool enabled) =>
      _prefs.setBool(_soundKey, enabled);
}
