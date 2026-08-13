import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'One tap. One life.'**
  String get appTagline;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @linkSkins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get linkSkins;

  /// No description provided for @linkShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get linkShop;

  /// No description provided for @linkStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get linkStats;

  /// No description provided for @linkMedals.
  ///
  /// In en, this message translates to:
  /// **'Medals'**
  String get linkMedals;

  /// No description provided for @dailyComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily complete'**
  String get dailyComplete;

  /// No description provided for @dailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily: {title}'**
  String dailyLabel(String title);

  /// No description provided for @bestScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Best {score}'**
  String bestScoreLabel(int score);

  /// No description provided for @titleNovice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get titleNovice;

  /// No description provided for @titleApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get titleApprentice;

  /// No description provided for @titleSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get titleSteady;

  /// No description provided for @titleRecordHunter.
  ///
  /// In en, this message translates to:
  /// **'Record hunter'**
  String get titleRecordHunter;

  /// No description provided for @titleMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get titleMinimalist;

  /// No description provided for @titleOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get titleOneMore;

  /// No description provided for @titleBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get titleBalance;

  /// No description provided for @titleOneMoreTry.
  ///
  /// In en, this message translates to:
  /// **'One more try.'**
  String get titleOneMoreTry;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to change lane'**
  String get tutorialTitle;

  /// No description provided for @tutorialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid blocks. One more try.'**
  String get tutorialSubtitle;

  /// No description provided for @tutorialCta.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to start'**
  String get tutorialCta;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialHint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to switch lanes'**
  String get tutorialHint;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @howToPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the basics anytime'**
  String get howToPlaySubtitle;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateApp;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the game? Leave a review'**
  String get rateAppSubtitle;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST'**
  String get newBest;

  /// No description provided for @dailyMissionComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily mission complete'**
  String get dailyMissionComplete;

  /// No description provided for @medalUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Medal unlocked'**
  String get medalUnlocked;

  /// No description provided for @newSkinUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New skin unlocked'**
  String get newSkinUnlocked;

  /// No description provided for @titlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Title: {name}'**
  String titlePrefix(String name);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'One more try.'**
  String get playAgain;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @skinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get skinsTitle;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equipped;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get equip;

  /// No description provided for @unlockHintScore.
  ///
  /// In en, this message translates to:
  /// **'Best score ≥ {n}'**
  String unlockHintScore(int n);

  /// No description provided for @unlockHintGames.
  ///
  /// In en, this message translates to:
  /// **'{n} games'**
  String unlockHintGames(int n);

  /// No description provided for @unlockHintDaily.
  ///
  /// In en, this message translates to:
  /// **'{n} daily missions'**
  String unlockHintDaily(int n);

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @sectionSkins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get sectionSkins;

  /// No description provided for @sectionPerks.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get sectionPerks;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @perkActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active — every run'**
  String get perkActiveLabel;

  /// No description provided for @perkPurchasedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{name} equipped — active in every run'**
  String perkPurchasedSnackbar(String name);

  /// No description provided for @medalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medals & Titles'**
  String get medalsTitle;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get statBestScore;

  /// No description provided for @statGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get statGamesPlayed;

  /// No description provided for @statAverage20.
  ///
  /// In en, this message translates to:
  /// **'Average (last 20)'**
  String get statAverage20;

  /// No description provided for @statTimePlayed.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get statTimePlayed;

  /// No description provided for @statMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String statMinutes(String n);

  /// No description provided for @statOrbsCollected.
  ///
  /// In en, this message translates to:
  /// **'Orbs collected'**
  String get statOrbsCollected;

  /// No description provided for @statDaysPlayed.
  ///
  /// In en, this message translates to:
  /// **'Days played'**
  String get statDaysPlayed;

  /// No description provided for @statRecordsBeaten.
  ///
  /// In en, this message translates to:
  /// **'Records beaten'**
  String get statRecordsBeaten;

  /// No description provided for @statDailyMissions.
  ///
  /// In en, this message translates to:
  /// **'Daily missions'**
  String get statDailyMissions;

  /// No description provided for @statSkinsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Skins unlocked'**
  String get statSkinsUnlocked;

  /// No description provided for @statMedals.
  ///
  /// In en, this message translates to:
  /// **'Medals'**
  String get statMedals;

  /// No description provided for @statDeathsPerLane.
  ///
  /// In en, this message translates to:
  /// **'Deaths L / C / R'**
  String get statDeathsPerLane;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{appName}\nOffline · Banner ads only · v1.0.0'**
  String aboutSubtitle(String appName);

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Art by Shade · Philippine Myth Creatures'**
  String get creditsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Progress is stored only on this device. AdMob may collect data per Google policy.'**
  String get privacyPolicySubtitle;

  /// No description provided for @creditsHeading.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsHeading;

  /// No description provided for @pixelArtLabel.
  ///
  /// In en, this message translates to:
  /// **'Pixel art'**
  String get pixelArtLabel;

  /// No description provided for @philippineMythCreatures.
  ///
  /// In en, this message translates to:
  /// **'Philippine Myth Creatures'**
  String get philippineMythCreatures;

  /// No description provided for @byShade.
  ///
  /// In en, this message translates to:
  /// **'by Shade'**
  String get byShade;

  /// No description provided for @cc0Note.
  ///
  /// In en, this message translates to:
  /// **'CC0 · itch.io pack used with thanks'**
  String get cc0Note;

  /// No description provided for @viewOnItch.
  ///
  /// In en, this message translates to:
  /// **'View on itch.io'**
  String get viewOnItch;

  /// No description provided for @uiArtLabel.
  ///
  /// In en, this message translates to:
  /// **'UI icons & shop skins'**
  String get uiArtLabel;

  /// No description provided for @superRetroWorldPack.
  ///
  /// In en, this message translates to:
  /// **'Super Retro World — Character Pack'**
  String get superRetroWorldPack;

  /// No description provided for @bySuperRetroAuthors.
  ///
  /// In en, this message translates to:
  /// **'by Gif, Noiracide & Romi'**
  String get bySuperRetroAuthors;

  /// No description provided for @superRetroLicenseNote.
  ///
  /// In en, this message translates to:
  /// **'Free to use with credit · itch.io pack'**
  String get superRetroLicenseNote;

  /// No description provided for @gameByPlanella.
  ///
  /// In en, this message translates to:
  /// **'One more try. — Planella'**
  String get gameByPlanella;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @medalFirstRunName.
  ///
  /// In en, this message translates to:
  /// **'First pulse'**
  String get medalFirstRunName;

  /// No description provided for @medalFirstRunDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish 1 game'**
  String get medalFirstRunDesc;

  /// No description provided for @medalScore50Name.
  ///
  /// In en, this message translates to:
  /// **'Awakening'**
  String get medalScore50Name;

  /// No description provided for @medalScore50Desc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 50'**
  String get medalScore50Desc;

  /// No description provided for @medalScore100Name.
  ///
  /// In en, this message translates to:
  /// **'In rhythm'**
  String get medalScore100Name;

  /// No description provided for @medalScore100Desc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 100'**
  String get medalScore100Desc;

  /// No description provided for @medalScore250Name.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get medalScore250Name;

  /// No description provided for @medalScore250Desc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 250'**
  String get medalScore250Desc;

  /// No description provided for @medalScore500Name.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get medalScore500Name;

  /// No description provided for @medalScore500Desc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 500'**
  String get medalScore500Desc;

  /// No description provided for @medalScore1000Name.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get medalScore1000Name;

  /// No description provided for @medalScore1000Desc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 1000'**
  String get medalScore1000Desc;

  /// No description provided for @medalGames50Name.
  ///
  /// In en, this message translates to:
  /// **'Persistent'**
  String get medalGames50Name;

  /// No description provided for @medalGames50Desc.
  ///
  /// In en, this message translates to:
  /// **'Play 50 games'**
  String get medalGames50Desc;

  /// No description provided for @medalGames200Name.
  ///
  /// In en, this message translates to:
  /// **'Habitual'**
  String get medalGames200Name;

  /// No description provided for @medalGames200Desc.
  ///
  /// In en, this message translates to:
  /// **'Play 200 games'**
  String get medalGames200Desc;

  /// No description provided for @medalDaily3Name.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get medalDaily3Name;

  /// No description provided for @medalDaily3Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 3 daily missions'**
  String get medalDaily3Desc;

  /// No description provided for @medalDaily7Name.
  ///
  /// In en, this message translates to:
  /// **'Perfect week'**
  String get medalDaily7Name;

  /// No description provided for @medalDaily7Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 7 daily missions'**
  String get medalDaily7Desc;

  /// No description provided for @medalNearMissName.
  ///
  /// In en, this message translates to:
  /// **'Almost…'**
  String get medalNearMissName;

  /// No description provided for @medalNearMissDesc.
  ///
  /// In en, this message translates to:
  /// **'10 games within 10 of your best'**
  String get medalNearMissDesc;

  /// No description provided for @medalNoCollectName.
  ///
  /// In en, this message translates to:
  /// **'Purist'**
  String get medalNoCollectName;

  /// No description provided for @medalNoCollectDesc.
  ///
  /// In en, this message translates to:
  /// **'Score ≥ 150 without orbs'**
  String get medalNoCollectDesc;

  /// No description provided for @medalCoins100Name.
  ///
  /// In en, this message translates to:
  /// **'Coin pouch'**
  String get medalCoins100Name;

  /// No description provided for @medalCoins100Desc.
  ///
  /// In en, this message translates to:
  /// **'Earn 10,000 coins total'**
  String get medalCoins100Desc;

  /// No description provided for @medalCoins500Name.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get medalCoins500Name;

  /// No description provided for @medalCoins500Desc.
  ///
  /// In en, this message translates to:
  /// **'Earn 50,000 coins total'**
  String get medalCoins500Desc;

  /// No description provided for @missionReach80.
  ///
  /// In en, this message translates to:
  /// **'Reach 80 in one run'**
  String get missionReach80;

  /// No description provided for @missionPlay5.
  ///
  /// In en, this message translates to:
  /// **'Play 5 games'**
  String get missionPlay5;

  /// No description provided for @missionOrbs30.
  ///
  /// In en, this message translates to:
  /// **'Collect 30 orbs'**
  String get missionOrbs30;

  /// No description provided for @missionSurvive60.
  ///
  /// In en, this message translates to:
  /// **'Survive 60 seconds'**
  String get missionSurvive60;

  /// No description provided for @missionReach120.
  ///
  /// In en, this message translates to:
  /// **'Reach 120 in one run'**
  String get missionReach120;

  /// No description provided for @perkBiggerMagnetName.
  ///
  /// In en, this message translates to:
  /// **'Bigger magnet'**
  String get perkBiggerMagnetName;

  /// No description provided for @perkBiggerMagnetDesc.
  ///
  /// In en, this message translates to:
  /// **'Magnet pickups pull from farther away'**
  String get perkBiggerMagnetDesc;

  /// No description provided for @perkStartWithShieldName.
  ///
  /// In en, this message translates to:
  /// **'Lucky start'**
  String get perkStartWithShieldName;

  /// No description provided for @perkStartWithShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Every run starts with a shield already up'**
  String get perkStartWithShieldDesc;

  /// No description provided for @perkRicherCoinsName.
  ///
  /// In en, this message translates to:
  /// **'Richer coins'**
  String get perkRicherCoinsName;

  /// No description provided for @perkRicherCoinsDesc.
  ///
  /// In en, this message translates to:
  /// **'Coin pickups are worth 100 extra coins'**
  String get perkRicherCoinsDesc;
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
      <String>['en', 'es', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
