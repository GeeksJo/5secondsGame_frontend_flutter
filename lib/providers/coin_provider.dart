import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import '../services/storage_service.dart';
import '../services/ads_flag.dart';

class CoinProvider extends ChangeNotifier {
  final StorageService _storage;
  late int _coins;
  late List<String> _purchased;

  static const int rentCost = 30;
  static const int buyCost = 100;
  static const int adReward = 20;
  static const Duration rentDuration = Duration(hours: 2);

  CoinProvider(this._storage) {
    _coins = _storage.getCoins();
    _purchased = _storage.getPurchasedCategories();
  }

  int get coins => _coins;

  bool isCategoryUnlocked(String categoryKey) {
    if (_purchased.contains(categoryKey)) return true;
    final expiry = _storage.getRentedExpiry(categoryKey);
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  Future<bool> rentCategory(String categoryKey) async {
    if (_coins < rentCost) return false;
    _coins -= rentCost;
    await _storage.setCoins(_coins);
    final expiry = DateTime.now().add(rentDuration);
    await _storage.setRentedExpiry(categoryKey, expiry);
    notifyListeners();
    return true;
  }

  Future<bool> buyCategory(String categoryKey) async {
    if (_coins < buyCost) return false;
    _coins -= buyCost;
    await _storage.setCoins(_coins);
    _purchased.add(categoryKey);
    await _storage.setPurchasedCategories(_purchased);
    notifyListeners();
    return true;
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _storage.setCoins(_coins);
    notifyListeners();
  }

  Future<bool> watchAdForCoins() async {
    if (!AdsFlag.enabled) return false;
    await GameKit.ads.loadRewarded();
    final rewarded = await GameKit.ads.showRewarded();
    if (rewarded) {
      await addCoins(adReward);
    }
    return rewarded;
  }

  bool get isAdReady => AdsFlag.enabled && GameKit.ads.isRewardedReady;
}
