class Player {
  final String name;
  int score;

  Player({required this.name, this.score = 0});

  void addPoint() => score++;

  void reset() => score = 0;
}
