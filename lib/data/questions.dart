import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionBank {
  List<Question> _allQuestions = [];
  final List<Question> _usedQuestions = [];
  final _random = Random();

  Future<void> load() async {
    const files = <String>[
      'assets/content/general.json',
      'assets/content/food.json',
      'assets/content/sports.json',
      'assets/content/movies.json',
      'assets/content/countriesandcapitals.json',
      'assets/content/animals.json',
      'assets/content/music.json',
      'assets/content/history.json',
      'assets/content/names.json',
      'assets/content/brands.json',
    ];

    final all = <Question>[];
    for (final path in files) {
      final jsonStr = await rootBundle.loadString(path);
      final data = json.decode(jsonStr);
      if (data is! Map<String, dynamic>) continue;
      final category = (data['category'] as String?) ?? '';
      final list = data['questions'];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is! Map) continue;
        final m = raw.cast<String, dynamic>();
        // Some files omit `category` per question; enforce it from the file header.
        m.putIfAbsent('category', () => category);
        all.add(Question.fromJson(m));
      }
    }
    _allQuestions = all;
  }

  Question? getQuestion(List<String> categoryKeys) {
    if (_allQuestions.isEmpty) return null;

    List<Question> matchingUnused() => _allQuestions
        .where(
          (q) =>
              categoryKeys.contains(q.category) && !_usedQuestions.contains(q),
        )
        .toList();

    List<Question> anyUnused() =>
        _allQuestions.where((q) => !_usedQuestions.contains(q)).toList();

    var pool = matchingUnused();
    if (pool.isEmpty && _usedQuestions.isNotEmpty) {
      _usedQuestions.clear();
      pool = matchingUnused();
    }
    if (pool.isEmpty) {
      pool = anyUnused();
    }
    if (pool.isEmpty) {
      return null;
    }

    final question = pool[_random.nextInt(pool.length)];
    _usedQuestions.add(question);
    return question;
  }

  void resetUsed() => _usedQuestions.clear();
}
