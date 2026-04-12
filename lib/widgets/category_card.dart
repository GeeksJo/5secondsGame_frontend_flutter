import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final GameCategory category;
  final String locale;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.locale,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isLocked ? Colors.grey : category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardFillDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey.shade700,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildVisual(accentColor),
                    const SizedBox(height: 12),
                    Text(
                      category.name(locale),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.lock, color: AppColors.coin, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(Color accentColor) {
    if (category.imagePath != null) {
      return ColorFiltered(
        colorFilter: isLocked
            ? const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ])
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Image.asset(
          category.imagePath!,
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),
      );
    }

    return Icon(
      category.icon,
      color: accentColor,
      size: 44,
    );
  }
}
