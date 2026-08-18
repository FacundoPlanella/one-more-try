// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'One tap. One life.';

  @override
  String get play => 'Play';

  @override
  String get linkSkins => 'Skins';

  @override
  String get linkShop => 'Shop';

  @override
  String get linkStats => 'Stats';

  @override
  String get linkMedals => 'Medals';

  @override
  String get dailyComplete => 'Daily complete';

  @override
  String dailyLabel(String title) {
    return 'Daily: $title';
  }

  @override
  String bestScoreLabel(int score) {
    return 'Best $score';
  }

  @override
  String get titleNovice => 'Novice';

  @override
  String get titleApprentice => 'Apprentice';

  @override
  String get titleSteady => 'Steady';

  @override
  String get titleRecordHunter => 'Record hunter';

  @override
  String get titleMinimalist => 'Minimalist';

  @override
  String get titleOneMore => 'One more';

  @override
  String get titleBalance => 'Balance';

  @override
  String get titleOneMoreTry => 'One more try.';

  @override
  String get tutorialTitle => 'Tap to change lane';

  @override
  String get tutorialSubtitle => 'Avoid blocks. One more try.';

  @override
  String get tutorialCta => 'Tap anywhere to start';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialHint => 'Tap anywhere to switch lanes';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get howToPlay => 'How to play';

  @override
  String get howToPlaySubtitle => 'Review the basics anytime';

  @override
  String get rateApp => 'Rate this app';

  @override
  String get rateAppSubtitle => 'Enjoying the game? Leave a review';

  @override
  String get contactSupport => 'Contact & feedback';

  @override
  String get contactSupportSubtitle => 'Send a suggestion or report a bug';

  @override
  String contactSupportEmailSubject(String appName) {
    return '$appName — feedback';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get newBest => 'NEW BEST';

  @override
  String get dailyMissionComplete => 'Daily mission complete';

  @override
  String get medalUnlocked => 'Medal unlocked';

  @override
  String get newSkinUnlocked => 'New skin unlocked';

  @override
  String titlePrefix(String name) {
    return 'Title: $name';
  }

  @override
  String get playAgain => 'One more try.';

  @override
  String get shareScore => 'Share score';

  @override
  String shareScoreMessage(int score) {
    return 'I scored $score in One more try.! Can you beat it?';
  }

  @override
  String get shareGame => 'Share game';

  @override
  String get shareGameMessage =>
      'One more try. — a one-tap endless runner. Give it a try!';

  @override
  String get menu => 'Menu';

  @override
  String get skinsTitle => 'Skins';

  @override
  String get equipped => 'Equipped';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get equip => 'Equip';

  @override
  String unlockHintScore(int n) {
    return 'Best score ≥ $n';
  }

  @override
  String unlockHintGames(int n) {
    return '$n games';
  }

  @override
  String unlockHintDaily(int n) {
    return '$n daily missions';
  }

  @override
  String get unlockHintShop => 'Available in Shop';

  @override
  String get shopTitle => 'Shop';

  @override
  String get sectionSkins => 'Skins';

  @override
  String get sectionPerks => 'Perks';

  @override
  String get owned => 'Owned';

  @override
  String get buy => 'Buy';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmPurchaseTitle => 'Confirm purchase?';

  @override
  String confirmPurchaseSkinMessage(String name, int price) {
    return 'You\'re about to buy $name for $price coins.';
  }

  @override
  String get perkActiveLabel => 'Active — every run';

  @override
  String perkPurchasedSnackbar(String name) {
    return '$name equipped — active in every run';
  }

  @override
  String skinPurchasedSnackbar(String name) {
    return '$name unlocked';
  }

  @override
  String get purchaseFailedSnackbar => 'Purchase couldn\'t be completed';

  @override
  String get medalsTitle => 'Medals & Titles';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statBestScore => 'Best score';

  @override
  String get statGamesPlayed => 'Games played';

  @override
  String get statAverage20 => 'Average (last 20)';

  @override
  String get statTimePlayed => 'Time played';

  @override
  String statMinutes(String n) {
    return '$n min';
  }

  @override
  String get statDistance => 'Distance traveled';

  @override
  String statMeters(Object n) {
    return '$n m';
  }

  @override
  String get statOrbsCollected => 'Orbs collected';

  @override
  String get statDaysPlayed => 'Days played';

  @override
  String get statRecordsBeaten => 'Records beaten';

  @override
  String get statDailyMissions => 'Daily missions';

  @override
  String get statSkinsUnlocked => 'Skins unlocked';

  @override
  String get statMedals => 'Medals';

  @override
  String get statDeathsPerLane => 'Deaths L / C / R';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get music => 'Music';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get haptics => 'Haptics';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get about => 'About';

  @override
  String aboutSubtitle(String appName) {
    return '$appName\nOffline · Banner ads only · v1.0.0';
  }

  @override
  String get credits => 'Credits';

  @override
  String get creditsSubtitle => 'Art by Shade · Philippine Myth Creatures';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicySubtitle =>
      'Progress is stored only on this device. AdMob may collect data per Google policy.';

  @override
  String get termsAndConditions => 'Terms & conditions';

  @override
  String get creditsHeading => 'Credits';

  @override
  String get pixelArtLabel => 'Pixel art';

  @override
  String get philippineMythCreatures => 'Philippine Myth Creatures';

  @override
  String get byShade => 'by Shade';

  @override
  String get cc0Note => 'CC0 · itch.io pack used with thanks';

  @override
  String get viewOnItch => 'View on itch.io';

  @override
  String get uiArtLabel => 'UI icons & shop skins';

  @override
  String get superRetroWorldPack => 'Super Retro World — Character Pack';

  @override
  String get bySuperRetroAuthors => 'by Gif, Noiracide & Romi';

  @override
  String get superRetroLicenseNote => 'Free to use with credit · itch.io pack';

  @override
  String get gameByPlanella => 'One more try. — Planella';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get medalFirstRunName => 'First pulse';

  @override
  String get medalFirstRunDesc => 'Finish 1 game';

  @override
  String get medalScore50Name => 'Awakening';

  @override
  String get medalScore50Desc => 'Score ≥ 50';

  @override
  String get medalScore100Name => 'In rhythm';

  @override
  String get medalScore100Desc => 'Score ≥ 100';

  @override
  String get medalScore250Name => 'Focus';

  @override
  String get medalScore250Desc => 'Score ≥ 250';

  @override
  String get medalScore500Name => 'Master';

  @override
  String get medalScore500Desc => 'Score ≥ 500';

  @override
  String get medalScore1000Name => 'Legend';

  @override
  String get medalScore1000Desc => 'Score ≥ 1000';

  @override
  String get medalGames50Name => 'Persistent';

  @override
  String get medalGames50Desc => 'Play 50 games';

  @override
  String get medalGames200Name => 'Habitual';

  @override
  String get medalGames200Desc => 'Play 200 games';

  @override
  String get medalDaily3Name => 'Consistency';

  @override
  String get medalDaily3Desc => 'Complete 3 daily missions';

  @override
  String get medalDaily7Name => 'Perfect week';

  @override
  String get medalDaily7Desc => 'Complete 7 daily missions';

  @override
  String get medalNearMissName => 'Almost…';

  @override
  String get medalNearMissDesc => '10 games within 10 of your best';

  @override
  String get medalNoCollectName => 'Purist';

  @override
  String get medalNoCollectDesc => 'Score ≥ 150 without orbs';

  @override
  String get medalCoins100Name => 'Coin pouch';

  @override
  String get medalCoins100Desc => 'Earn 10,000 coins total';

  @override
  String get medalCoins500Name => 'Treasury';

  @override
  String get medalCoins500Desc => 'Earn 50,000 coins total';

  @override
  String get missionReach80 => 'Reach 80 in one run';

  @override
  String get missionPlay5 => 'Play 5 games';

  @override
  String get missionOrbs30 => 'Collect 30 orbs';

  @override
  String get missionSurvive60 => 'Survive 60 seconds';

  @override
  String get missionReach120 => 'Reach 120 in one run';

  @override
  String get perkBiggerMagnetName => 'Bigger magnet';

  @override
  String get perkBiggerMagnetDesc => 'Magnet pickups pull from farther away';

  @override
  String get perkStartWithShieldName => 'Lucky start';

  @override
  String get perkStartWithShieldDesc =>
      'Every run starts with a shield already up';

  @override
  String get perkRicherCoinsName => 'Richer coins';

  @override
  String get perkRicherCoinsDesc => 'Coin pickups are worth 100 extra coins';
}
