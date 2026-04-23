import 'package:game_kit/game_kit.dart';

import 'storage_service.dart';

/// Local donation totals plus read-through of ad-free state from [GameKit.iap].
class PremiumService {
  PremiumService(this._storage);

  final StorageService _storage;

  Future<bool> areAdsRemoved() async => GameKit.iap.adsRemoved.value;

  /// No-op: ad-free state is driven by Store / game_kit. Reserved for tests.
  Future<void> setAdsRemoved(bool value) async {}

  Future<void> addDonation(String productId, double amount) async {
    await _storage.addDonationAmount(amount);
  }

  Future<double> getTotalDonations() async => _storage.getDonationTotalAmount();

  /// Clears locally tracked donations only (debug).
  Future<void> resetPremiumFeatures() async {
    await _storage.clearDonationTotal();
  }
}
