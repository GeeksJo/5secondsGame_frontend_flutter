import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import '../services/storage_service.dart';

class CoinProvider extends ChangeNotifier {
  final StorageService _storage;
  late int _coins;
  late List<String> _purchased;

  static const int rentCost = 30;
  static const int buyCost = 100;
  static const int adReward = 20;
  static const Duration rentDuration = Duration(hours: 2);

  static const Duration _rewardedLoadCap = Duration(seconds: 5);
  static const Duration _rewardedShowCap = Duration(seconds: 30);

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
    if (!GameKit.ads.canShowRewarded(RewardedReason.hint)) {
      return false;
    }

    if (!GameKit.ads.isRewardedReady) {
      try {
        await GameKit.ads
            .loadRewarded()
            .timeout(_rewardedLoadCap, onTimeout: () {});
      } catch (_) {}
    }

    if (!GameKit.ads.isRewardedReady) {
      return false;
    }

    try {
      final rewarded = await GameKit.ads
          .showRewarded()
          .timeout(_rewardedShowCap, onTimeout: () => false);
      if (rewarded) {
        await addCoins(adReward);
      }
      return rewarded;
    } catch (_) {
      return false;
    }
  }

  bool get isAdReady =>
      GameKit.ads.canShowRewarded(RewardedReason.hint) &&
      GameKit.ads.isRewardedReady;
}
