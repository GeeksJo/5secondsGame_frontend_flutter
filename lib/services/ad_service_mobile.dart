import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

AdService createAdService() => MobileAdService();

class MobileAdService implements AdService {
  // =============================================================
  // SETTINGS
  // =============================================================

  static const Duration _interstitialCooldown = Duration(seconds: 35);
  static const int _maxFailedLoadAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 5);
  static const Duration _loadTimeout = Duration(seconds: 30);

  // =============================================================
  // AD UNIT IDS (test IDs — swap for production)
  // =============================================================

  String get _rewardedId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  String get _interstitialId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  String get _bannerId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  // =============================================================
  // INTERNAL STATE
  // =============================================================

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _isLoadingRewarded = false;
  bool _isLoadingInterstitial = false;

  int _rewardedLoadAttempts = 0;
  int _interstitialLoadAttempts = 0;

  DateTime? _lastInterstitialShow;

  // =============================================================
  // INITIALIZATION
  // =============================================================

  @override
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _loadRewarded();
      _loadInterstitial();
    } catch (_) {}
  }

  // =============================================================
  // REWARDED AD
  // =============================================================

  void _loadRewarded() {
    if (_isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    try {
      RewardedAd.load(
        adUnitId: _rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoadingRewarded = false;
            _rewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoadingRewarded = false;
            _rewardedLoadAttempts++;
            if (_rewardedLoadAttempts <= _maxFailedLoadAttempts) {
              Future.delayed(_retryDelay, _loadRewarded);
            }
          },
        ),
      );
    } catch (_) {
      _isLoadingRewarded = false;
    }
  }

  @override
  bool get isAdReady => _rewardedAd != null;

  @override
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      _loadRewarded();
      return false;
    }

    bool rewarded = false;
    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
      },
    );

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () => false,
    );
  }

  // =============================================================
  // INTERSTITIAL AD
  // =============================================================

  void _loadInterstitial() {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    try {
      InterstitialAd.load(
        adUnitId: _interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoadingInterstitial = false;
            _interstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _isLoadingInterstitial = false;
            _interstitialLoadAttempts++;
            if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
              Future.delayed(_retryDelay, _loadInterstitial);
            }
          },
        ),
      );
    } catch (_) {
      _isLoadingInterstitial = false;
    }
  }

  @override
  bool get isInterstitialReady => _interstitialAd != null;

  bool get _isCooldownActive =>
      _lastInterstitialShow != null &&
      DateTime.now().difference(_lastInterstitialShow!) < _interstitialCooldown;

  @override
  Future<void> showInterstitial() async {
    if (_interstitialAd == null) {
      _loadInterstitial();
      return;
    }

    if (_isCooldownActive) return;

    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );

    _lastInterstitialShow = DateTime.now();
    await _interstitialAd!.show();

    return completer.future.timeout(
      _loadTimeout,
      onTimeout: () {},
    );
  }

  // =============================================================
  // BANNER AD
  // =============================================================

  @override
  Widget getBannerWidget() => _BannerAdWidget(adUnitId: _bannerId);

  // =============================================================
  // CLEANUP
  // =============================================================

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

// =============================================================
// BANNER WIDGET
// =============================================================

class _BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  const _BannerAdWidget({required this.adUnitId});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
