import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionBank {
  List<Question> _allQuestions = [];
  final List<Question> _usedQuestions = [];
  final _random = Random();

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/questions/questions.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = data['questions'] as List;
    _allQuestions = list.map((q) => Question.fromJson(q)).toList();
  }

  Question? getQuestion(List<String> categoryKeys) {
    final available = _allQuestions
        .where((q) =>
            categoryKeys.contains(q.category) && !_usedQuestions.contains(q))
        .toList();

    if (available.isEmpty) {
      _usedQuestions.clear();
      return getQuestion(categoryKeys);
    }

    final question = available[_random.nextInt(available.length)];
    _usedQuestions.add(question);
    return question;
  }

  void resetUsed() => _usedQuestions.clear();
}
