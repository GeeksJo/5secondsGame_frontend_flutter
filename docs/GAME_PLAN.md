# Yalla (يلا) — Game Plan (Final)

## Overview

A Flutter party game app where players take turns answering category-based questions in 5 seconds. Supports **1v1** (screen flip) and **free-for-all** (pass the phone). Arabic-first with English support. Features a **coin economy** with locked categories, rewarded ads, and rent/buy unlocking.

---

## Game Flow

```
Home Screen (يلا branding, Play, How to Play, Settings gear, coin balance)
  → Choose Mode (1v1 or Free-for-All)
  → Enter Player Names (2 for 1v1, 3+ for FFA)
  → Choose Number of Rounds (default 3, options: 1/3/5/7/10)
  → Pick Categories (multi-select, some locked with coin system)
  → Ready Screen ("[Player], get ready!")
  → Question Screen (5-second timer + red DONE button)
      → Player presses DONE → +1 point, +1 coin
      → Timer runs out → 0 points, 0 coins
  → Pass/Flip Screen
      → 1v1: screen flips 180°
      → FFA: "Pass to [Next Player]"
  → Loop until all rounds complete
  → Scoreboard (rankings + coins earned, play again)
```

---

## Screens (10 total)

| # | Screen | Description |
|---|--------|-------------|
| 1 | Home | App name "يلا" in white, blue gradient, Play button, How to Play, Settings gear, coin display |
| 2 | Settings | Language toggle (AR/EN), sound on/off |
| 3 | How to Play | Step-by-step illustrated rules |
| 4 | Mode Selection | Two cards: 1v1 and Free-for-All |
| 5 | Player Setup | Name entry (2 for 1v1, 3+ for FFA with add/remove) |
| 6 | Round Selection | Pick rounds: 1, 3, 5, 7, or 10 |
| 7 | Category Selection | Blue gradient, black cards, colored icons, multi-select, locked categories with rent/buy bottom sheet, coin balance |
| 8 | Ready | "[Player], get ready!" with Start button, round counter |
| 9 | Question | Question text, 5-second animated timer, big red DONE button |
| 10 | Scoreboard | Ranked results, coins earned, Play Again / Home |

---

## Coin Economy

| Action | Coins |
|--------|-------|
| Correct answer | +1 |
| Watch rewarded ad | +20 |
| Rent a category (2 hours) | -30 |
| Buy a category (permanent) | -100 |
| Starting balance | 50 |

Coins stored locally via SharedPreferences.

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Localization | flutter_localizations + ARB files (Arabic-first) |
| Fonts | Cairo (Arabic), Poppins (English) via google_fonts |
| Ads | Google AdMob (google_mobile_ads) |
| Persistence | SharedPreferences |
| Backend | None — fully offline |

---

## Project Structure

```
lib/
  main.dart
  app.dart
  theme/
    app_theme.dart              # Centralized colors, gradients, radii, spacing, decorations, button styles
  l10n/
    app_ar.arb                  # Arabic strings (template)
    app_en.arb                  # English strings
    app_localizations.dart      # Generated
  models/
    player.dart
    question.dart
    category.dart
    game_state.dart
  providers/
    game_provider.dart
    locale_provider.dart
    coin_provider.dart
  screens/
    home_screen.dart
    settings_screen.dart
    how_to_play_screen.dart
    mode_selection_screen.dart
    player_setup_screen.dart
    round_selection_screen.dart
    category_selection_screen.dart
    ready_screen.dart
    question_screen.dart
    pass_screen.dart
    scoreboard_screen.dart
  widgets/
    countdown_timer.dart
    red_button.dart
    category_card.dart
    locked_category_sheet.dart
    player_score_tile.dart
  data/
    questions.dart
  services/
    ad_service.dart
    storage_service.dart
assets/
  questions/
    questions.json              # 140+ bilingual questions across 9 categories
docs/
  GAME_PLAN.md
```

---

## Centralized Theme (lib/theme/app_theme.dart)

All colors, gradients, spacing, radii, decorations, and button styles are defined in one file:

- **AppColors**: primary, primaryDark, surface, coin, correct, danger, cardFill, cardBorder, textPrimary/Secondary/Muted/Hint/Disabled
- **AppGradients**: primary (blue), dark (deeper blue for question screen)
- **AppRadius**: sm(8), md(12), lg(16), xl(20), pill(26), round(28)
- **AppSpacing**: screenPadding, screenH, cardPadding, buttonHeight, buttonHeightLg
- **AppDecorations**: gradientBg, darkGradientBg, card, cardWithBorder, bottomSheet
- **AppButtonStyles**: primary, primaryDisabled
- **buildAppTheme()**: locale-aware ThemeData with Cairo/Poppins fonts

---

## Question Bank

- 9 categories: Food, Sports, Movies, Countries, Animals, Music, Science, History, Brands
- 140+ questions total (~15-18 per category)
- Each question bilingual (text_en + text_ar)
- Locked categories: Animals, Music, Science, Brands (configurable via `lockedByDefault` flag)
