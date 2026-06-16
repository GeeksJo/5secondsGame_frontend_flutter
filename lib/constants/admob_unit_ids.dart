/// Production AdMob unit IDs for this app.
///
/// Also declared in [AndroidManifest.xml] / [Info.plist]. Kept here so release
/// builds still resolve ad units when [.env] is missing from the asset bundle.
abstract final class AdMobUnitIds {
  static const bannerAndroid = 'ca-app-pub-1281176583312027/7038100538';
  static const bannerIos = 'ca-app-pub-1281176583312027/7481473189';
  static const interstitialAndroid = 'ca-app-pub-1281176583312027/8682354691';
  static const interstitialIos = 'ca-app-pub-1281176583312027/5102202338';
}
