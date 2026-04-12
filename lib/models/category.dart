import 'package:flutter/material.dart';

class GameCategory {
  final String key;
  final String nameEn;
  final String nameAr;
  final IconData icon;
  final Color color;
  final bool lockedByDefault;
  final String? imagePath;

  const GameCategory({
    required this.key,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
    required this.color,
    this.lockedByDefault = false,
    this.imagePath,
  });

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  static const List<GameCategory> all = [
    GameCategory(
      key: 'food',
      nameEn: 'Food',
      nameAr: 'طعام',
      icon: Icons.restaurant,
      color: Colors.orange,
      imagePath: 'assets/images/categories/restaurant.png',
    ),
    GameCategory(
      key: 'sports',
      nameEn: 'Sports',
      nameAr: 'رياضة',
      icon: Icons.sports_soccer,
      color: Colors.green,
      imagePath: 'assets/images/categories/football.png',
    ),
    GameCategory(
      key: 'movies',
      nameEn: 'Movies',
      nameAr: 'أفلام',
      icon: Icons.movie,
      color: Colors.red,
      imagePath: 'assets/images/categories/emotions.png',
    ),
    GameCategory(
      key: 'countries',
      nameEn: 'Countries',
      nameAr: 'دول',
      icon: Icons.public,
      color: Colors.blue,
      imagePath: 'assets/images/categories/travel.png',
    ),
    GameCategory(
      key: 'animals',
      nameEn: 'Animals',
      nameAr: 'حيوانات',
      icon: Icons.pets,
      color: Colors.amber,
      lockedByDefault: true,
      imagePath: 'assets/images/categories/cooking.png',
    ),
    GameCategory(
      key: 'music',
      nameEn: 'Music',
      nameAr: 'موسيقى',
      icon: Icons.music_note,
      color: Colors.purple,
      lockedByDefault: true,
      imagePath: 'assets/images/categories/guitar.png',
    ),
    GameCategory(
      key: 'science',
      nameEn: 'Science',
      nameAr: 'علوم',
      icon: Icons.science,
      color: Colors.teal,
      lockedByDefault: true,
      imagePath: 'assets/images/categories/gamble.png',
    ),
    GameCategory(
      key: 'history',
      nameEn: 'History',
      nameAr: 'تاريخ',
      icon: Icons.history_edu,
      color: Colors.brown,
    ),
    GameCategory(
      key: 'brands',
      nameEn: 'Brands',
      nameAr: 'ماركات',
      icon: Icons.store,
      color: Colors.pink,
      lockedByDefault: true,
      imagePath: 'assets/images/categories/social-media.png',
    ),
  ];
}
