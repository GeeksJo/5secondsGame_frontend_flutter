import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'يلا'**
  String get appName;

  /// No description provided for @play.
  ///
  /// In ar, this message translates to:
  /// **'العب'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In ar, this message translates to:
  /// **'كيف تلعب'**
  String get howToPlay;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get sound;

  /// No description provided for @on.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get on;

  /// No description provided for @off.
  ///
  /// In ar, this message translates to:
  /// **'مطفأ'**
  String get off;

  /// No description provided for @oneVsOne.
  ///
  /// In ar, this message translates to:
  /// **'١ ضد ١'**
  String get oneVsOne;

  /// No description provided for @freeForAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل ضد الكل'**
  String get freeForAll;

  /// No description provided for @oneVsOneDesc.
  ///
  /// In ar, this message translates to:
  /// **'لاعبين اثنين، الهاتف ينقلب بينهم'**
  String get oneVsOneDesc;

  /// No description provided for @freeForAllDesc.
  ///
  /// In ar, this message translates to:
  /// **'٣ لاعبين أو أكثر، مرر الهاتف'**
  String get freeForAllDesc;

  /// No description provided for @playerSetup.
  ///
  /// In ar, this message translates to:
  /// **'أسماء اللاعبين'**
  String get playerSetup;

  /// No description provided for @enterPlayerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم اللاعب'**
  String get enterPlayerName;

  /// No description provided for @addPlayer.
  ///
  /// In ar, this message translates to:
  /// **'أضف لاعب'**
  String get addPlayer;

  /// No description provided for @removePlayer.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get removePlayer;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @rounds.
  ///
  /// In ar, this message translates to:
  /// **'الجولات'**
  String get rounds;

  /// No description provided for @howManyRounds.
  ///
  /// In ar, this message translates to:
  /// **'كم جولة؟'**
  String get howManyRounds;

  /// No description provided for @chooseCategories.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئات'**
  String get chooseCategories;

  /// No description provided for @getReady.
  ///
  /// In ar, this message translates to:
  /// **'استعد!'**
  String get getReady;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم!'**
  String get done;

  /// No description provided for @timeUp.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت!'**
  String get timeUp;

  /// No description provided for @passTo.
  ///
  /// In ar, this message translates to:
  /// **'مرر الهاتف إلى'**
  String get passTo;

  /// No description provided for @tapToContinue.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للمتابعة'**
  String get tapToContinue;

  /// No description provided for @scoreboard.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get scoreboard;

  /// No description provided for @playAgain.
  ///
  /// In ar, this message translates to:
  /// **'العب مرة ثانية'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @coins.
  ///
  /// In ar, this message translates to:
  /// **'عملات'**
  String get coins;

  /// No description provided for @coinsEarned.
  ///
  /// In ar, this message translates to:
  /// **'عملات مكتسبة'**
  String get coinsEarned;

  /// No description provided for @rent.
  ///
  /// In ar, this message translates to:
  /// **'استئجار'**
  String get rent;

  /// No description provided for @buy.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get buy;

  /// No description provided for @rentFor2Hours.
  ///
  /// In ar, this message translates to:
  /// **'استئجار لمدة ساعتين'**
  String get rentFor2Hours;

  /// No description provided for @buyForever.
  ///
  /// In ar, this message translates to:
  /// **'شراء للأبد'**
  String get buyForever;

  /// No description provided for @watchAd.
  ///
  /// In ar, this message translates to:
  /// **'شاهد إعلان'**
  String get watchAd;

  /// No description provided for @earnCoins.
  ///
  /// In ar, this message translates to:
  /// **'اكسب ٢٠ عملة'**
  String get earnCoins;

  /// No description provided for @locked.
  ///
  /// In ar, this message translates to:
  /// **'مقفل'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get unlocked;

  /// No description provided for @notEnoughCoins.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك عملات كافية'**
  String get notEnoughCoins;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة واحدة على الأقل'**
  String get selectAtLeastOne;

  /// No description provided for @player.
  ///
  /// In ar, this message translates to:
  /// **'لاعب'**
  String get player;

  /// No description provided for @round.
  ///
  /// In ar, this message translates to:
  /// **'جولة'**
  String get round;

  /// No description provided for @score.
  ///
  /// In ar, this message translates to:
  /// **'النقاط'**
  String get score;

  /// No description provided for @winner.
  ///
  /// In ar, this message translates to:
  /// **'الفائز'**
  String get winner;

  /// No description provided for @howToPlayStep1.
  ///
  /// In ar, this message translates to:
  /// **'اختر وضع اللعب وأدخل أسماء اللاعبين'**
  String get howToPlayStep1;

  /// No description provided for @howToPlayStep2.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئات وعدد الجولات'**
  String get howToPlayStep2;

  /// No description provided for @howToPlayStep3.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر لك سؤال ولديك ٥ ثوانٍ للإجابة'**
  String get howToPlayStep3;

  /// No description provided for @howToPlayStep4.
  ///
  /// In ar, this message translates to:
  /// **'أجب بصوت عالٍ واضغط الزر الأحمر إذا أجبت'**
  String get howToPlayStep4;

  /// No description provided for @howToPlayStep5.
  ///
  /// In ar, this message translates to:
  /// **'إذا لم تستطع الإجابة، سينتهي الوقت تلقائياً'**
  String get howToPlayStep5;

  /// No description provided for @howToPlayStep6.
  ///
  /// In ar, this message translates to:
  /// **'أكثر لاعب يجمع نقاط يفوز!'**
  String get howToPlayStep6;

  /// No description provided for @paused.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get resume;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'٥ ثوانٍ'**
  String get appSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
