import '../models/player.dart';
import '../models/question.dart';

/// Fixture for previewing [ScoreboardScreen] in debug builds.
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   builder: (_) => ScoreboardScreen(
///     debugRankedPlayers: ScoreboardScreenTestData.rankedPlayersFixture(),
///   ),
/// ));
/// ```
final class ScoreboardScreenTestData {
  ScoreboardScreenTestData._();

  /// Matches the “coins earned” total from the five-player preview (sum of scores).
  static const int totalCoinsEarned = 27;

  static const Question sampleQuestion = Question(
    category: 'brands',
    count: 3,
    textEn: 'Name 3 brands you remember from childhood ads',
    textAr: 'اذكر ٣ ماركات تتذكرها من إعلانات الطفولة',
  );

  /// Pre-sorted: highest score first (same order as the reference Results screen).
  static List<Player> rankedPlayersFixture() => [
        Player(name: 'حاتم', score: 7),
        Player(name: 'يزن', score: 6),
        Player(name: 'زين', score: 6),
        Player(name: 'سميرة', score: 4),
        Player(name: 'محمد', score: 4),
      ];
}
