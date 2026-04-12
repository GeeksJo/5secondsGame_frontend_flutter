import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/coin_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/coin_display.dart';
import '../widgets/locked_category_sheet.dart';
import '../widgets/responsive_layout.dart';
import 'ready_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final Set<String> _selected = {};
  int _selectedRounds = 3;
  static const _roundOptions = [1, 3, 5, 7, 10];

  void _onCategoryTap(GameCategory category, bool isLocked) {
    if (isLocked) {
      _showLockedSheet(category);
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(category.key)) {
        _selected.remove(category.key);
      } else {
        _selected.add(category.key);
      }
    });
  }

  void _showLockedSheet(GameCategory category) async {
    final unlocked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CoinProvider>(),
        child: LockedCategorySheet(category: category),
      ),
    );

    if (unlocked == true && mounted) {
      setState(() {
        _selected.add(category.key);
      });
    }
  }

  void _onStart() {
    final game = context.read<GameProvider>();
    game.setTotalRounds(_selectedRounds);
    game.setCategories(_selected.toList());
    game.startGame();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReadyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final isArabic = locale == 'ar';
    final coinProvider = context.watch<CoinProvider>();
    final isTablet = ResponsiveLayout.isTablet(context);
    final gridCols = ResponsiveLayout.gridColumns(context);
    final roundChipSize = isTablet ? 56.0 : 48.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: SafeArea(
          child: ResponsiveLayout(
            maxWidth: 800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const CoinDisplay(),
                    ],
                  ),
                ),
                Text(
                  l10n.appName,
                  style: (isArabic
                          ? GoogleFonts.cairo(
                              fontSize: isTablet ? 44.0 : 36.0,
                              fontWeight: FontWeight.w900)
                          : GoogleFonts.poppins(
                              fontSize: isTablet ? 44.0 : 36.0,
                              fontWeight: FontWeight.w900))
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.howManyRounds,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: isTablet ? 18.0 : 15.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _roundOptions.map((n) {
                    final active = _selectedRounds == n;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedRounds = n);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: roundChipSize,
                          height: roundChipSize,
                          decoration: BoxDecoration(
                            color: active ? AppColors.textPrimary : AppColors.cardFill,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: active ? AppColors.textPrimary : AppColors.cardBorder,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: TextStyle(
                                color: active ? AppColors.primary : AppColors.textPrimary,
                                fontSize: isTablet ? 22.0 : 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                Text(
                  l10n.chooseCategories,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: isTablet ? 18.0 : 15.0,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: GameCategory.all.length,
                    itemBuilder: (context, index) {
                      final cat = GameCategory.all[index];
                      final isLocked = cat.lockedByDefault &&
                          !coinProvider.isCategoryUnlocked(cat.key);

                      return CategoryCard(
                        category: cat,
                        locale: locale,
                        isSelected: _selected.contains(cat.key),
                        isLocked: isLocked,
                        onTap: () => _onCategoryTap(cat, isLocked),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: AppSpacing.screenPadding,
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _selected.isNotEmpty ? _onStart : null,
                      style: AppButtonStyles.primaryDisabled,
                      child: Text(
                        _selected.isEmpty ? l10n.selectAtLeastOne : l10n.start,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
