class Question {
  final String category;
  final int count;
  final String textEn;
  final String textAr;

  const Question({
    required this.category,
    required this.count,
    required this.textEn,
    required this.textAr,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'] as String,
      count: json['count'] as int,
      textEn: json['text_en'] as String,
      textAr: json['text_ar'] as String,
    );
  }

  String text(String locale) => locale == 'ar' ? textAr : textEn;
}
