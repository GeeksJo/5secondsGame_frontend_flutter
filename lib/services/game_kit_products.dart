/// Store product IDs shared by [GameKitConfig] and IAP prefetch / Settings UI.
abstract final class GameKitProducts {
  static const removeAds = 'com.majoon.yalla.remove_ads';
  static const donationSmall = 'com.majoon.yalla.donation_small';
  static const donationMedium = 'com.majoon.yalla.donation_medium';
  static const donationLarge = 'com.majoon.yalla.donation_large';

  static Set<String> get all => {
    removeAds,
    donationSmall,
    donationMedium,
    donationLarge,
  };

  /// In-app feedback mail (used after a negative rating path).
  static Uri get feedbackMailto => Uri.parse(
    'mailto:support@majoon.app?subject=Yalla%20feedback',
  );

  static Uri get websiteUrl => Uri.parse('https://majoon.app');
}
