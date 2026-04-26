import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_navigator.dart';
import 'game_kit_products.dart';
import 'storage_service.dart';

/// Call sites for `game_kit` in this app:
///
/// - [GameKit.ads.levelCompleted] — end of match on [ScoreboardScreen] (`failed: false`).
/// - [GameKit.ads.adClosed] — [GameKitAdBridge] after each interstitial; [presentOnAbandonHome].
/// - [GameKit.ads.canShowRewarded] — before rewarded in [LockedCategorySheet].
/// - [GameKit.notifications.markPlayedToday] — first frame [QuestionScreen].
/// - [GameKit.notifications.initialize] — inside [GameKit.initialize] on cold start;
///   [refreshGameKitAfterResume] calls it again on app resume ([YallaApp] lifecycle).
/// - [GameKit.notifications.onFirstDailyCompletion] — [ScoreboardScreen] first frame.
/// - [GameKit.rating.levelSucceeded] — after each correct answer [QuestionScreen].
/// - [GameKit.iap] — purchases / restore / prices in [SettingsScreen] & [QuestionScreen].
/// - [GameKit.crossPromo] — catalog sheet; badge on home settings.
/// - [GameKit.share] — settings share row.
/// - [GameKit.haptics] — question & scoreboard.
Future<void> initializeGameKit(StorageService storage) async {
  await GameKit.initialize(
    GameKitConfig(
      iap: IapConfig(
        removeAdsProductId: GameKitProducts.removeAds,
        donationSmallProductId: GameKitProducts.donationSmall,
        donationMediumProductId: GameKitProducts.donationMedium,
        donationLargeProductId: GameKitProducts.donationLarge,
        donationAmountsByProductId: {
          GameKitProducts.donationSmall: 0.99,
          GameKitProducts.donationMedium: 4.99,
          GameKitProducts.donationLarge: 9.99,
        },
      ),
      ads: AdsConfig(
        interstitialEveryNLevels: 2,
        adMobEnvironment: AdMobUnitEnvironment.test,
        prodAdMobUnitIds: AdMobProdUnitIds(
          interstitialAndroid: AdMobGoogleSampleUnitIds.interstitialAndroid,
          interstitialIos: AdMobGoogleSampleUnitIds.interstitialIos,
          bannerAndroid: AdMobGoogleSampleUnitIds.bannerAndroid,
          bannerIos: AdMobGoogleSampleUnitIds.bannerIos,
          rewardedAndroid: AdMobGoogleSampleUnitIds.rewardedAndroid,
          rewardedIos: AdMobGoogleSampleUnitIds.rewardedIos,
        ),
        interstitialMaxPerSession: 8,
        interstitialCooldownSeconds: 30,
      ),
      rating: const RatingConfig(),
      notifications: const NotificationsConfig(
        days: [DateTime.monday, DateTime.wednesday, DateTime.friday],
        hour: 18,
        androidChannelId: 'yalla_reminders',
        androidChannelName: 'Yalla',
        androidChannelDescription: 'Reminders to play',
        notificationTitle: 'Yalla',
        notificationBody: 'Play a quick round today.',
      ),
      share: const ShareConfig(
        appName: 'Yalla! - 5 seconds',
        androidPackageName: 'com.majoon.yalla',
      ),
      storage: const StorageConfig(
        backend: GameKitStoreBackend.sharedPreferences,
      ),
    ),
  );

  unawaited(GameKit.ads.loadInterstitial());
  unawaited(GameKit.ads.loadRewarded());

  await _migrateLegacyDonationTotal(storage);
  await _prefetchIapCatalog();
  GameKitAdBridge.attach();
  _listenRatingPrompts();
}

/// Moves `StorageService` donation total into [GameKit.iap] once, if present.
Future<void> _migrateLegacyDonationTotal(StorageService storage) async {
  try {
    final legacy = storage.getDonationTotalAmount();
    if (legacy <= 0) return;
    final current = await GameKit.iap.getTotalDonations();
    if (current > 0) {
      await storage.clearDonationTotal();
      return;
    }
    await GameKit.iap.addDonation(GameKitProducts.donationSmall, legacy);
    await storage.clearDonationTotal();
  } catch (_) {}
}

Future<void> _prefetchIapCatalog() async {
  if (!GameKit.iap.isAvailable) return;
  try {
    await GameKit.iap.loadStoreProducts();
  } catch (_) {}
}

Future<void> refreshGameKitAfterResume() async {
  try {
    await GameKit.notifications.initialize();
  } catch (_) {}
}

void _listenRatingPrompts() {
  GameKit.rating.onShouldShowSoftPrompt.listen((_) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctx.mounted) {
        unawaited(_showRatingSoftDialog(ctx));
      }
    });
  });

  GameKit.rating.onShouldShowFeedbackForm.listen((_) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctx.mounted) {
        unawaited(_showRatingFeedbackDialog(ctx));
      }
    });
  });
}

Future<void> _showRatingSoftDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      title: const Text('Enjoying Yalla?'),
      content: const Text('A quick rating helps others find the game.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            unawaited(GameKit.rating.respond(RatingResponse.positive));
          },
          child: const Text('Love it'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            unawaited(GameKit.rating.respond(RatingResponse.negative));
          },
          child: const Text('Not really'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            unawaited(GameKit.rating.respond(RatingResponse.dismissed));
          },
          child: const Text('Later'),
        ),
      ],
    ),
  );
}

Future<void> _showRatingFeedbackDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Tell us more'),
      content: const Text('Send us a quick email with your thoughts.'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(c);
            final u = GameKitProducts.feedbackMailto;
            if (await canLaunchUrl(u)) {
              await launchUrl(u);
            }
            unawaited(GameKit.rating.respond(RatingResponse.dismissed));
          },
          child: const Text('Email'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            unawaited(GameKit.rating.respond(RatingResponse.dismissed));
          },
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// `onShouldShowInterstitial` → [GameKit.ads] load/show → [GameKit.ads.adClosed].
final class GameKitAdBridge {
  GameKitAdBridge._();

  static StreamSubscription<void>? _sub;
  static Completer<void>? _waiter;

  static void attach() {
    _sub?.cancel();
    _sub = GameKit.ads.onShouldShowInterstitial.listen((_) {
      unawaited(_present());
    });
  }

  static Future<void> _present() async {
    try {
      await GameKit.ads.loadInterstitial();
      await GameKit.ads.showInterstitial();
    } finally {
      await GameKit.ads.adClosed();
      if (_waiter != null && !_waiter!.isCompleted) {
        _waiter!.complete();
      }
    }
  }

  static Future<void> presentAfterLevel({required bool failed}) async {
    if (GameKit.iap.adsRemoved.value) return;
    _waiter = Completer<void>();
    await GameKit.ads.levelCompleted(failed: failed);
    try {
      await _waiter!.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {},
      );
    } finally {
      if (_waiter != null && !_waiter!.isCompleted) {
        _waiter!.complete();
      }
      _waiter = null;
    }
  }

  static Future<void> presentOnAbandonHome() async {
    if (GameKit.iap.adsRemoved.value) return;
    try {
      await GameKit.ads.loadInterstitial();
      await GameKit.ads.showInterstitial();
    } finally {
      await GameKit.ads.adClosed();
    }
  }

  static Future<void> detach() async {
    await _sub?.cancel();
    _sub = null;
  }
}
