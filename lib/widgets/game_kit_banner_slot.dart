import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ads_flag.dart';

/// Loads an anchored adaptive banner via [GameKit.ads] (dispose-safe).
class GameKitBannerSlot extends StatefulWidget {
  const GameKitBannerSlot({super.key});

  @override
  State<GameKitBannerSlot> createState() => _GameKitBannerSlotState();
}

class _GameKitBannerSlotState extends State<GameKitBannerSlot> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!AdsFlag.enabled) return;
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    final ad = await GameKit.ads.loadBannerAd(size: size);
    if (!mounted) {
      ad?.dispose();
      return;
    }
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
