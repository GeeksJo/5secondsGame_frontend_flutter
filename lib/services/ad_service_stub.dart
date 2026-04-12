import 'package:flutter/widgets.dart';
import 'ad_service.dart';

AdService createAdService() => StubAdService();

class StubAdService implements AdService {
  @override
  Future<void> init() async {}

  @override
  bool get isAdReady => false;

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  Widget getBannerWidget() => const SizedBox.shrink();

  @override
  bool get isInterstitialReady => false;

  @override
  Future<void> showInterstitial() async {}

  @override
  void dispose() {}
}
