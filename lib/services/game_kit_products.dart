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
}
