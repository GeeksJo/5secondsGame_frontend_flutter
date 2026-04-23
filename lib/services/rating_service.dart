import 'package:game_kit/game_kit.dart';

/// Opens the store listing for rating (delegates to game_kit).
class RatingService {
  RatingService._();

  static Future<void> openStoreDirectly() => GameKit.rating.openStoreListing();
}
