/// Store product IDs shared by [GameKitConfig] and IAP prefetch / Settings UI.
abstract final class GameKitProducts {
  static const removeAds = 'yalla.remove_ads';
  static const donationSmall = 'yalla.donation_small';
  static const donationMedium = 'yalla.donation_medium';
  static const donationLarge = 'yalla.donation_large';

  static Set<String> get all => {
    removeAds,
    donationSmall,
    donationMedium,
    donationLarge,
  };

  /// In-app feedback mail (used after a negative rating path).
  static Uri get feedbackMailto => Uri.parse(
    'mailto:support@majoon.app?subject=Yalla%21%20-%205%20seconds%20feedback',
  );

  static Uri get websiteUrl => Uri.parse('https://majoon.app');
}
