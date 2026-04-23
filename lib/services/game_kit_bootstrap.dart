import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ad_service.dart';
import 'app_navigator.dart';
import 'game_kit_products.dart';

/// Call sites for `game_kit` in this app:
///
/// - [GameKit.ads.levelCompleted] — end of match on [ScoreboardScreen] (`failed: false`).
/// - [GameKit.ads.adClosed] — [GameKitAdBridge] after each interstitial; [presentOnAbandonHome]
///   after pause → Home (manual interstitial + [adClosed]).
/// - [GameKit.ads.canShowRewarded] — before rewarded in [LockedCategorySheet].
/// - [GameKit.notifications.markPlayedToday] — first frame [QuestionScreen].
/// - [GameKit.notifications.initialize] — again on app resume ([YallaApp] lifecycle).
/// - [GameKit.notifications.onFirstDailyCompletion] — [ScoreboardScreen] first frame.
/// - [GameKit.rating.levelSucceeded] — after each correct answer [QuestionScreen].
/// - [GameKit.iap.loadProducts] / purchase / restore — [PurchaseService] + [SettingsScreen].
/// - [GameKit.crossPromo] — catalog sheet from Settings; badge on home settings.
/// - [GameKit.haptics] — correct move (question), level complete (scoreboard).
Future<void> initializeGameKit(AdService adService) async {
  await GameKit.initialize(
    GameKitConfig(
      iap: const IapConfig(
        removeAdsProductId: GameKitProducts.removeAds,
        donationSmallProductId: GameKitProducts.donationSmall,
        donationMediumProductId: GameKitProducts.donationMedium,
        donationLargeProductId: GameKitProducts.donationLarge,
      ),
      ads: const AdsConfig(
        interstitialEveryNLevels: 2,
        maxPerSession: 8,
        cooldownSeconds: 30,
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
      crossPromo: const CrossPromoConfig(
        apiUrl: 'https://example.com/yalla-promo-games.json',
        cacheDays: 3,
      ),
      storage: const StorageConfig(
        backend: GameKitStoreBackend.sharedPreferences,
      ),
    ),
  );

  await _prefetchIapCatalog();
  GameKitAdBridge.attach(adService);
  _listenRemoveAdsTooltip();
  _listenRatingPrompts();
}

Future<void> _prefetchIapCatalog() async {
  if (!GameKit.iap.isAvailable) return;
  try {
    await GameKit.iap.loadProducts(GameKitProducts.all);
  } catch (_) {}
}

Future<void> refreshGameKitAfterResume() async {
  try {
    await GameKit.notifications.initialize();
  } catch (_) {}
}

void _listenRemoveAdsTooltip() {
  GameKit.ads.onShouldShowRemoveAdsTooltip.listen((_) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text('Remove ads?'),
          action: SnackBarAction(
            label: 'Buy',
            onPressed: () {
              unawaited(GameKit.iap.purchaseRemoveAds());
            },
          ),
        ),
      );
    });
  });
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
      content: const Text(
        'Send us a quick email with your thoughts.',
      ),
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

/// `onShouldShowInterstitial` → AdMob → [GameKit.ads.adClosed].
final class GameKitAdBridge {
  GameKitAdBridge._();

  static StreamSubscription<void>? _sub;
  static Completer<void>? _waiter;

  static void attach(AdService ads) {
    _sub?.cancel();
    _sub = GameKit.ads.onShouldShowInterstitial.listen((_) {
      unawaited(_present(ads));
    });
  }

  static Future<void> _present(AdService ads) async {
    try {
      await ads.showInterstitial();
    } finally {
      await GameKit.ads.adClosed();
      if (_waiter != null && !_waiter!.isCompleted) {
        _waiter!.complete();
      }
    }
  }

  static Future<void> presentAfterLevel(
    AdService ads, {
    required bool failed,
  }) async {
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

  static Future<void> presentOnAbandonHome(AdService ads) async {
    if (GameKit.iap.adsRemoved.value) return;
    try {
      await ads.showInterstitial();
    } finally {
      await GameKit.ads.adClosed();
    }
  }

  static Future<void> detach() async {
    await _sub?.cancel();
    _sub = null;
  }
}
