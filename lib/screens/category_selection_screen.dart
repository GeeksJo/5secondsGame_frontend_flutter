import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yalla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/coin_provider.dart';
import '../providers/game_provider.dart';
import '../providers/game_settings_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/locked_category_sheet.dart';
import '../widgets/responsive_layout.dart';
import 'stage_start_screen.dart';

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
  late final Future<List<GameCategory>> _categoriesFuture = GameCategory.loadAll();

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

  Widget _buildAnswerTimeRow(
    AppLocalizations l10n,
    GameSettingsProvider settings,
  ) {
    final seconds = settings.questionTimerSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.answerTime,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$seconds s',
                style: const TextStyle(
                  fontFamily: AppFonts.family,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.coin,
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: AppColors.textPrimary,
            ),
            child: Slider(
              value: seconds.toDouble(),
              min: GameSettingsProvider.minQuestionTimerSeconds.toDouble(),
              max: GameSettingsProvider.maxQuestionTimerSeconds.toDouble(),
              divisions:
                  GameSettingsProvider.maxQuestionTimerSeconds -
                  GameSettingsProvider.minQuestionTimerSeconds,
              onChanged: (v) => context
                  .read<GameSettingsProvider>()
                  .setQuestionTimerSeconds(v.round()),
            ),
          ),
        ],
      ),
    );
  }

  void _onStart() {
    final game = context.read<GameProvider>();
    game.setTotalRounds(_selectedRounds);
    game.setCategories(_selected.toList());
    game.startGame();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StageStartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final coinProvider = context.watch<CoinProvider>();
    final gameSettings = context.watch<GameSettingsProvider>();
    final isTablet = ResponsiveLayout.isTablet(context);
    final gridCols = ResponsiveLayout.gridColumns(context);
    final roundChipSize = isTablet ? 48.0 : 40.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            maxWidth: 800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          l10n.chooseCategories,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.family,
                            color: AppColors.textPrimary,
                            fontSize: isTablet ? 17 : 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.howManyRounds,
                      style: const TextStyle(
                        fontFamily: AppFonts.family,
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _roundOptions.map((n) {
                    final active = _selectedRounds == n;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedRounds = n);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: roundChipSize,
                          height: roundChipSize,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.cardFill,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: active
                                  ? AppColors.textPrimary
                                  : AppColors.cardBorder,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontFamily: AppFonts.family,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontSize: isTablet ? 18.0 : 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                _buildAnswerTimeRow(l10n, gameSettings),
                const SizedBox(height: 6),

                Expanded(
                  child: FutureBuilder<List<GameCategory>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      final categories =
                          snapshot.data ?? GameCategory.allFallback;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCols,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isLocked =
                              cat.lockedByDefault &&
                              !coinProvider.isCategoryUnlocked(cat.key);

                          return CategoryCard(
                            category: cat,
                            locale: locale,
                            isSelected: _selected.contains(cat.key),
                            isLocked: isLocked,
                            onTap: () => _onCategoryTap(cat, isLocked),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    6,
                    20,
                    MediaQuery.paddingOf(context).bottom,
                  ),
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
