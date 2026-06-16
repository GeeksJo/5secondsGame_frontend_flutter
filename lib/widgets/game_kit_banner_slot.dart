import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ads_flag.dart';
import '../services/game_kit_bootstrap.dart';

/// Loads an anchored adaptive banner via [GameKit.ads].
///
/// Tears down before fullscreen interstitials so iOS does not hit
/// `recreating_view` when the banner [AdWidget] is remounted.
class GameKitBannerSlot extends StatefulWidget {
  const GameKitBannerSlot({super.key});

  @override
  State<GameKitBannerSlot> createState() => _GameKitBannerSlotState();
}

class _GameKitBannerSlotState extends State<GameKitBannerSlot> {
  BannerAd? _ad;
  int _loadGeneration = 0;
  bool _loading = false;
  int _loadedForWidth = 0;

  @override
  void initState() {
    super.initState();
    GameKitAdBridge.interstitialPresenting.addListener(_onInterstitialChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  @override
  void dispose() {
    GameKitAdBridge.interstitialPresenting.removeListener(_onInterstitialChange);
    _disposeAd(immediate: true, rebuild: false);
    super.dispose();
  }

  void _onInterstitialChange() {
    if (GameKitAdBridge.interstitialPresenting.value) {
      _disposeAd();
      return;
    }
    // Wait two frames so iOS can tear down the old UiKitView before reloading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybeLoad();
      });
    });
  }

  void _disposeAd({bool immediate = false, bool rebuild = true}) {
    final ad = _ad;
    if (ad == null) return;
    _ad = null;
    _loadedForWidth = 0;
    _loadGeneration++;
    if (rebuild && mounted) setState(() {});

    void disposeNative() => ad.dispose();
    if (immediate) {
      disposeNative();
    } else {
      // Let [AdWidget] unmount before tearing down the native view.
      WidgetsBinding.instance.addPostFrameCallback((_) => disposeNative());
    }
  }

  Future<void> _maybeLoad() async {
    if (!AdsFlag.enabled) return;
    if (!mounted) return;
    if (GameKitAdBridge.interstitialPresenting.value) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0) return;
    if (_loading) return;
    if (_ad != null && _loadedForWidth == width) return;

    if (_ad != null && _loadedForWidth != width) {
      _disposeAd();
    }

    await _load(width: width);
  }

  Future<void> _load({required int width}) async {
    if (!AdsFlag.enabled) return;
    if (!mounted) return;
    if (GameKitAdBridge.interstitialPresenting.value) return;
    if (_loading || _ad != null) return;

    _loading = true;
    final generation = ++_loadGeneration;
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (!mounted || size == null || generation != _loadGeneration) return;
      if (GameKitAdBridge.interstitialPresenting.value) return;

      final ad = await GameKit.ads.loadBannerAd(size: size);
      if (!mounted || generation != _loadGeneration) {
        ad?.dispose();
        return;
      }
      if (GameKitAdBridge.interstitialPresenting.value) {
        ad?.dispose();
        return;
      }

      setState(() {
        _ad = ad;
        _loadedForWidth = width;
      });
    } finally {
      if (generation == _loadGeneration) _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (GameKitAdBridge.interstitialPresenting.value) {
      return const SizedBox.shrink();
    }
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      key: ValueKey(identityHashCode(ad)),
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
