import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const String _assetPath = 'assets/content/categories.json';

  static Future<List<GameCategory>> loadAll() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return allFallback;
      return decoded
          .whereType<Map>()
          .map((m) => GameCategory.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return allFallback;
    }
  }

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      key: (json['key'] as String?) ?? '',
      nameEn: (json['nameEn'] as String?) ?? '',
      nameAr: (json['nameAr'] as String?) ?? '',
      icon: _iconFromString((json['icon'] as String?) ?? ''),
      color: _colorFromHex((json['color'] as String?) ?? '#FFFFFF'),
      lockedByDefault: (json['lockedByDefault'] as bool?) ?? false,
      imagePath: json['imagePath'] as String?,
    );
  }

  static IconData _iconFromString(String v) {
    return switch (v) {
      'restaurant' => Icons.restaurant,
      'sports_soccer' => Icons.sports_soccer,
      'movie' => Icons.movie,
      'public' => Icons.public,
      'pets' => Icons.pets,
      'music_note' => Icons.music_note,
      'science' => Icons.science,
      'history_edu' => Icons.history_edu,
      'store' => Icons.store,
      'badge' => Icons.badge,
      _ => Icons.category,
    };
  }

  static Color _colorFromHex(String v) {
    var hex = v.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16) ?? 0xFFFFFFFF;
    return Color(value);
  }

  /// Fallback list used if the JSON asset can't be read/parsed.
  static const List<GameCategory> allFallback = [
    GameCategory(
      key: 'general',
      nameEn: 'General',
      nameAr: 'عام',
      icon: Icons.category,
      color: Colors.green,
      imagePath: 'assets/images/categories/general.png',
    ),
    GameCategory(
      key: 'food',
      nameEn: 'Food',
      nameAr: 'طعام',
      icon: Icons.restaurant,
      color: Colors.orange,
      imagePath: 'assets/images/categories/food.png',
    ),
    GameCategory(
      key: 'sports',
      nameEn: 'Sports',
      nameAr: 'رياضة',
      icon: Icons.sports_soccer,
      color: Colors.green,
      imagePath: 'assets/images/categories/sports.png',
    ),
    GameCategory(
      key: 'movies',
      nameEn: 'Movies',
      nameAr: 'أفلام',
      icon: Icons.movie,
      color: Colors.red,
      imagePath: 'assets/images/categories/movies.png',
    ),
    GameCategory(
      key: 'countriesandcapitals',
      nameEn: 'Countries & Capitals',
      nameAr: 'دول وعواصم',
      icon: Icons.public,
      color: Colors.blue,
      imagePath: 'assets/images/categories/countriesandcapitals.png',
    ),
    GameCategory(
      key: 'animals',
      nameEn: 'Animals',
      nameAr: 'حيوانات',
      icon: Icons.pets,
      color: Colors.amber,
      imagePath: 'assets/images/categories/animals.png',
    ),
    GameCategory(
      key: 'music',
      nameEn: 'Music',
      nameAr: 'موسيقى',
      icon: Icons.music_note,
      color: Colors.purple,
      imagePath: 'assets/images/categories/music.png',
    ),
    GameCategory(
      key: 'history',
      nameEn: 'History',
      nameAr: 'تاريخ',
      icon: Icons.history_edu,
      color: Colors.brown,
      imagePath: 'assets/images/categories/history.png',
    ),
    GameCategory(
      key: 'names',
      nameEn: 'Names',
      nameAr: 'أسماء',
      icon: Icons.badge,
      color: Colors.purple,
      imagePath: 'assets/images/categories/names.png',
    ),
    GameCategory(
      key: 'brands',
      nameEn: 'Brands',
      nameAr: 'ماركات',
      icon: Icons.store,
      color: Colors.pink,
      imagePath: 'assets/images/categories/brands.png',
    ),
  ];
}
