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
  Question? _currentQuestion;
  int _coinsEarnedThisGame = 0;

  final QuestionBank _questionBank;

  GameProvider(this._questionBank);

  GameMode get mode => _mode;
  List<Player> get players => _players;
  List<String> get selectedCategories => _selectedCategories;
  int get totalRounds => _totalRounds;
  int get currentRound => _currentRound;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player get currentPlayer => _players[_currentPlayerIndex];
  Question? get currentQuestion => _currentQuestion;
  int get coinsEarnedThisGame => _coinsEarnedThisGame;
  bool get isGameOver => _currentRound > _totalRounds;

  void setMode(GameMode mode) {
    _mode = mode;
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
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _coinsEarnedThisGame = 0;
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
    _coinsEarnedThisGame++;
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

  void resetGame() {
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _coinsEarnedThisGame = 0;
    for (final p in _players) {
      p.reset();
    }
    _questionBank.resetUsed();
    notifyListeners();
  }
}
