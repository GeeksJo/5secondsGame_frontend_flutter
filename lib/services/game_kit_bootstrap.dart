import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game_kit/game_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import 'ads_flag.dart';
import 'app_navigator.dart';
import 'game_kit_products.dart';
import 'storage_service.dart';

/// Call sites for `game_kit` in this app:
///
/// - [GameKit.ads.levelCompleted] — between rounds in [QuestionScreen] and at
///   end of match on [ScoreboardScreen] (`failed: true` skips cadence on timeout).
/// - [GameKit.ads.adClosed] — [GameKitAdBridge] after each interstitial; [presentOnAbandonHome].
/// - [GameKit.ads.canShowRewarded] — before rewarded in [LockedCategorySheet].
/// - [GameKit.notifications.markPlayedToday] — first frame [QuestionScreen].
/// - [GameKit.notifications.initialize] — inside [GameKit.initialize] on cold start;
///   [refreshGameKitAfterResume] calls it again on app resume ([YallaApp] lifecycle).
/// - [GameKit.notifications.onFirstDailyCompletion] — [ScoreboardScreen] first frame.
/// - [GameKit.rating.levelSucceeded] — after each correct answer [QuestionScreen]
///   with cumulative [StorageService.incrementRatingSuccessCount] (not in-game round).
/// - [GameKit.iap] — purchases / restore / prices in [SettingsScreen] & [QuestionScreen].
/// - [GameKit.crossPromo] — catalog sheet; badge on home settings.
/// - [GameKit.share] — settings share row.
/// - [GameKit.haptics] / [GameKit.sounds] — gameplay feedback (countdown, answers, UI).
Future<void> initializeGameKit(StorageService storage) async {
  final persistedLocale = Locale(storage.getLocale());

  String env(String key) => (dotenv.env[key] ?? '').trim();
  String envOr(String key, String fallback) {
    final v = env(key);
    return v.isEmpty ? fallback : v;
  }

  // By default, ads are disabled in release builds.
  // This is intentionally a compile-time flag to keep it deterministic per build.
  final adsEnabled = AdsFlag.enabled;
  await GameKit.initialize(
    GameKitConfig(
      locale: persistedLocale,
      crossPromoSheetSeedColor: AppColors.primary,
      settingsUi: GameKitSettingsUiConfig(
        seedColor: AppColors.primary,
        iconColor: AppColors.primary,
        fontFamily: AppFonts.family,
        sectionCardAppearance: GameKitSectionCardAppearance.frosted,
        showCrossPromo: true,
        dialog: GameKitSettingsDialogUiConfig(
          darkSurfaceColor: AppColors.surface,
          darkBorderColor: AppColors.cardBorder,
          darkTitleColor: AppColors.textPrimary,
          darkBodyColor: AppColors.textSecondary,
          alertSurfaceColor: AppColors.surface,
          alertOutlineColor: AppColors.cardBorder,
          alertTitleColor: AppColors.textPrimary,
          alertBodyColor: AppColors.textSecondary,
        ),
      ),
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
        interstitialEveryNLevels: 1,
        adMobEnvironment: AdMobUnitEnvironment.test,
        prodAdMobUnitIds: AdMobProdUnitIds(
          interstitialAndroid: envOr(
            'ADMOB_ANDROID_INTERSTITIAL_ID',
            AdMobGoogleSampleUnitIds.interstitialAndroid,
          ),
          interstitialIos: envOr(
            'ADMOB_IOS_INTERSTITIAL_ID',
            AdMobGoogleSampleUnitIds.interstitialIos,
          ),
          bannerAndroid: envOr(
            'ADMOB_ANDROID_BANNER_ID',
            AdMobGoogleSampleUnitIds.bannerAndroid,
          ),
          bannerIos: envOr(
            'ADMOB_IOS_BANNER_ID',
            AdMobGoogleSampleUnitIds.bannerIos,
          ),
          rewardedAndroid: envOr(
            'ADMOB_ANDROID_REWARDED_ID',
            AdMobGoogleSampleUnitIds.rewardedAndroid,
          ),
          rewardedIos: envOr(
            'ADMOB_IOS_REWARDED_ID',
            AdMobGoogleSampleUnitIds.rewardedIos,
          ),
        ),
        interstitialMaxPerSession: 8,
        interstitialCooldownSeconds: 60,
      ),
      // [minLevel] is compared to a *cumulative* success count (see
      // [StorageService.incrementRatingSuccessCount]), not in-game round index.
      // [minSession] 1: first app session can show a prompt once other gates pass
      // (default 2 would require a second cold start before any prompt).
      rating: const RatingConfig(minSession: 1),
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
      sound: const SoundConfig(respectSilentMode: false),
      haptics: HapticsConfig(isEnabled: () => storage.getHapticsEnabled()),
      crossPromoAppIdentifier: 'com.majoon.yalla',
    ),
  );

  await _migrateAudioHapticsPreferences(storage);

  if (adsEnabled) {
    await GameKit.ads.loadInterstitial();
    unawaited(GameKit.ads.loadRewarded());
  }

  await _migrateLegacyDonationTotal(storage);
  await _prefetchIapCatalog();
  if (adsEnabled) {
    GameKitAdBridge.attach();
  }
  _listenRatingPrompts();
  _listenRemoveAdsTooltip();
}

/// Copies legacy [sound_enabled] into GameKit preferences and seeds haptics.
Future<void> _migrateAudioHapticsPreferences(StorageService storage) async {
  const kitSoundKey = 'game_kit.preferences.soundsEnabled';
  const hapticsMigratedKey = 'haptics_pref_migrated_v1';

  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(kitSoundKey)) {
    final legacy = storage.getLegacySoundEnabledOrNull() ?? true;
    await GameKit.preferences.setSoundsEnabled(legacy);
  }

  if (prefs.getBool(hapticsMigratedKey) != true) {
    final legacy = storage.getLegacySoundEnabledOrNull();
    if (legacy != null) {
      await storage.setHapticsEnabled(legacy);
    }
    await prefs.setBool(hapticsMigratedKey, true);
  }
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
    final prefs = await SharedPreferences.getInstance();
    const prefix = 'game_kit.iap.';
    final existing = prefs.getInt('${prefix}totalDonationsCents');
    if (existing == null || existing <= 0) {
      await prefs.setInt(
        '${prefix}totalDonationsCents',
        (legacy * 100).round(),
      );
    }
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
  GameKitAdBridge.preloadInterstitial();
}

void _listenRemoveAdsTooltip() {
  GameKit.ads.onShouldShowRemoveAdsTooltip.listen((_) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctx.mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      final l10n = GameKitLocalizations.of(ctx);
      messenger?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.settingsRemoveAdsSubtitle,
            style: TextStyle(fontFamily: GameKit.settingsUi?.fontFamily),
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
      content: const Text('Send us a quick email with your thoughts.'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(c);
            final u = GameKitDefaultContact.feedbackMailto;
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

  /// True while a fullscreen interstitial is loading/showing.
  /// Banner slots listen to this to avoid iOS platform-view id collisions.
  static final ValueNotifier<bool> interstitialPresenting = ValueNotifier(
    false,
  );

  static void attach() {
    // Interstitials are shown from [presentAfterLevel] directly.
  }

  /// Fire-and-forget interstitial preload (no-op when ads are off or removed).
  static void preloadInterstitial() {
    if (!AdsFlag.enabled) return;
    if (GameKit.iap.adsRemoved.value) return;
    unawaited(GameKit.ads.loadInterstitial());
  }

  static Future<bool> _loadAndShowInterstitial({
    Duration loadTimeout = const Duration(seconds: 4),
  }) async {
    try {
      await GameKit.ads.loadInterstitial().timeout(
        loadTimeout,
        onTimeout: () {},
      );
    } catch (_) {}
    return GameKit.ads.showInterstitial();
  }

  static Future<void> _present() async {
    if (!AdsFlag.enabled) return;
    interstitialPresenting.value = true;
    try {
      await _loadAndShowInterstitial();
    } finally {
      interstitialPresenting.value = false;
      await GameKit.ads.adClosed();
      preloadInterstitial();
    }
  }

  static Future<void> presentAfterLevel({required bool failed}) async {
    if (!AdsFlag.enabled) return;
    if (GameKit.iap.adsRemoved.value) return;

    var shouldShow = false;
    final sub = GameKit.ads.onShouldShowInterstitial.listen((_) {
      shouldShow = true;
    });
    try {
      await GameKit.ads.levelCompleted(failed: failed);
    } finally {
      await sub.cancel();
    }

    if (!shouldShow) return;
    await _present();
  }

  static Future<void> presentOnAbandonHome() async {
    if (!AdsFlag.enabled) return;
    if (GameKit.iap.adsRemoved.value) return;
    interstitialPresenting.value = true;
    try {
      await _loadAndShowInterstitial();
    } finally {
      interstitialPresenting.value = false;
      await GameKit.ads.adClosed();
      preloadInterstitial();
    }
  }

  static Future<void> detach() async {}
}
