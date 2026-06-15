import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../models/game_state.dart';
import '../data/questions.dart';

class GameProvider extends ChangeNotifier {
  GameMode _mode = GameMode.oneVsOne;
  List<Player> _players = [];
  List<String> _selectedCategories = [];
  int _totalRounds = 3;
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  bool _isFlipped = false;
  Question? _currentQuestion;

  final QuestionBank _questionBank;

  GameProvider(this._questionBank);

  GameMode get mode => _mode;
  List<Player> get players => _players;
  List<String> get selectedCategories => _selectedCategories;
  int get totalRounds => _totalRounds;
  int get currentRound => _currentRound;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player get currentPlayer => _players[_currentPlayerIndex];
  bool get isFlipped => _isFlipped;
  Question? get currentQuestion => _currentQuestion;
  bool get isGameOver => _currentRound > _totalRounds;

  void setMode(GameMode mode) {
    _mode = mode;
    _isFlipped = false;
    notifyListeners();
  }

  void setPlayers(List<String> names) {
    _players = names.map((n) => Player(name: n)).toList();
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setTotalRounds(int rounds) {
    _totalRounds = rounds;
    notifyListeners();
  }

  void startGame() {
    if (_players.isEmpty) {
      notifyListeners();
      return;
    }
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _isFlipped = false;
    for (final p in _players) {
      p.reset();
    }
    _questionBank.resetUsed();
    _nextQuestion();
    notifyListeners();
  }

  void _nextQuestion() {
    _currentQuestion = _questionBank.getQuestion(_selectedCategories);
  }

  bool answerCorrect() {
    currentPlayer.addPoint();
    final gameOver = _advanceTurn();
    notifyListeners();
    return gameOver;
  }

  bool answerTimeout() {
    final gameOver = _advanceTurn();
    notifyListeners();
    return gameOver;
  }

  bool _advanceTurn() {
    _currentPlayerIndex++;
    if (_currentPlayerIndex >= _players.length) {
      _currentPlayerIndex = 0;
      _currentRound++;
    }
    if (_currentRound > _totalRounds) {
      return true;
    }
    if (_mode == GameMode.oneVsOne && _players.length == 2) {
      _isFlipped = !_isFlipped;
    }
    _nextQuestion();
    return false;
  }

  Player get winner {
    final sorted = List<Player>.from(_players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted.first;
  }

  List<Player> get rankedPlayers {
    final sorted = List<Player>.from(_players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// True when exactly one player has the highest score.
  bool get hasSingleWinner {
    if (_players.isEmpty) return false;
    final topScore = rankedPlayers.first.score;
    return rankedPlayers.where((p) => p.score == topScore).length == 1;
  }

  bool get isDraw => _players.isNotEmpty && !hasSingleWinner;

  void resetGame() {
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _isFlipped = false;
    for (final p in _players) {
      p.reset();
    }
    _questionBank.resetUsed();
    notifyListeners();
  }
}
