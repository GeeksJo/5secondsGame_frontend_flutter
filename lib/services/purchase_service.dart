import 'dart:async';

import 'package:game_kit/game_kit.dart';

import 'game_kit_products.dart';

/// Bridges [GameKit.iap] to a small stream-based API for the settings UI.
/// Billing is owned by game_kit (not the `in_app_purchase` package directly).
class PurchaseService {
  PurchaseService();

  final _purchaseComplete = StreamController<String>.broadcast();
  final _purchaseRestored = StreamController<String>.broadcast();
  final _purchaseError = StreamController<String>.broadcast();
  final _purchaseStarted = StreamController<void>.broadcast();
  final _restoreComplete = StreamController<bool>.broadcast();

  Stream<String> get onPurchaseComplete => _purchaseComplete.stream;
  Stream<String> get onPurchaseRestored => _purchaseRestored.stream;
  Stream<String> get onPurchaseError => _purchaseError.stream;
  Stream<void> get onPurchaseStarted => _purchaseStarted.stream;
  Stream<bool> get onRestoreComplete => _restoreComplete.stream;

  bool _attached = false;
  final List<StreamSubscription<dynamic>> _subs = [];

  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  bool get isAvailable => GameKit.iap.isAvailable;

  void initialize() {
    if (_attached) return;
    _attached = true;

    _subs.add(
      GameKit.iap.onPurchaseComplete.listen(
        _purchaseComplete.add,
        onError: (Object e) => _purchaseError.add(e.toString()),
      ),
    );
    _subs.add(
      GameKit.iap.onPurchaseError.listen(
        (_) => _purchaseError.add('purchase_failed'),
      ),
    );
  }

  String getFormattedPrice(String productId) =>
      GameKit.iap.getFormattedPrice(productId);

  Future<void> purchaseProduct(String productId) async {
    if (!isAvailable) {
      _purchaseError.add('store_unavailable');
      return;
    }
    _purchaseStarted.add(null);
    try {
      if (productId == GameKitProducts.removeAds) {
        await GameKit.iap.purchaseRemoveAds();
        return;
      }
      if (productId == GameKitProducts.donationSmall) {
        await GameKit.iap.purchaseDonation(DonationTier.small);
        return;
      }
      if (productId == GameKitProducts.donationMedium) {
        await GameKit.iap.purchaseDonation(DonationTier.medium);
        return;
      }
      if (productId == GameKitProducts.donationLarge) {
        await GameKit.iap.purchaseDonation(DonationTier.large);
        return;
      }
      _purchaseError.add('product_not_found');
    } catch (e) {
      _purchaseError.add(e.toString());
    }
  }

  Future<bool> restorePurchases() async {
    if (!isAvailable) {
      _restoreComplete.add(false);
      return false;
    }
    _isRestoring = true;
    final completer = Completer<bool>();
    StreamSubscription<bool>? sub;
    sub = GameKit.iap.onRestoreComplete.listen((ok) {
      if (!completer.isCompleted) completer.complete(ok);
    });
    try {
      await GameKit.iap.restore();
      final ok = await completer.future.timeout(
        const Duration(seconds: 90),
        onTimeout: () => false,
      );
      _restoreComplete.add(ok);
      if (ok && GameKit.iap.adsRemoved.value) {
        _purchaseRestored.add(GameKitProducts.removeAds);
      }
      return ok;
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
      _restoreComplete.add(false);
      return false;
    } finally {
      await sub.cancel();
      _isRestoring = false;
    }
  }

  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
    unawaited(_purchaseComplete.close());
    unawaited(_purchaseRestored.close());
    unawaited(_purchaseError.close());
    unawaited(_purchaseStarted.close());
    unawaited(_restoreComplete.close());
  }
}
