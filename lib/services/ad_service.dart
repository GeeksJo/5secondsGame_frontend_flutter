import 'package:flutter/widgets.dart';
import 'ad_service_mobile.dart' if (dart.library.html) 'ad_service_stub.dart'
    as platform;

abstract class AdService {
  factory AdService() => platform.createAdService();

  Future<void> init();

  // Rewarded
  bool get isAdReady;
  Future<bool> showRewardedAd();

  // Banner
  Widget getBannerWidget();

  // Interstitial
  bool get isInterstitialReady;
  Future<void> showInterstitial();

  void dispose();
}
