import 'package:flutter/widgets.dart';

import '../../domain/entities/skin.dart';
import '../../l10n/generated/app_localizations.dart';

/// Traduce los ids de progresión (título, medallas, misión diaria, perks) y
/// el hint de desbloqueo de skins. Los catálogos de dominio solo guardan
/// ids/números; el texto final vive acá para poder localizarlo.
class TitleLabel {
  static String resolve(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'aprendiz':
        return t.titleApprentice;
      case 'constante':
        return t.titleSteady;
      case 'cazador':
        return t.titleRecordHunter;
      case 'minimalista':
        return t.titleMinimalist;
      case 'uno_mas':
        return t.titleOneMore;
      case 'equilibrio':
        return t.titleBalance;
      case 'one_more_try':
        return t.titleOneMoreTry;
      default:
        return t.titleNovice;
    }
  }
}

class MedalLabels {
  static String name(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'first_run':
        return t.medalFirstRunName;
      case 'score_50':
        return t.medalScore50Name;
      case 'score_100':
        return t.medalScore100Name;
      case 'score_250':
        return t.medalScore250Name;
      case 'score_500':
        return t.medalScore500Name;
      case 'score_1000':
        return t.medalScore1000Name;
      case 'games_50':
        return t.medalGames50Name;
      case 'games_200':
        return t.medalGames200Name;
      case 'daily_3':
        return t.medalDaily3Name;
      case 'daily_7':
        return t.medalDaily7Name;
      case 'near_miss':
        return t.medalNearMissName;
      case 'no_collect':
        return t.medalNoCollectName;
      case 'coins_100':
        return t.medalCoins100Name;
      case 'coins_500':
        return t.medalCoins500Name;
      default:
        return id;
    }
  }

  static String description(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'first_run':
        return t.medalFirstRunDesc;
      case 'score_50':
        return t.medalScore50Desc;
      case 'score_100':
        return t.medalScore100Desc;
      case 'score_250':
        return t.medalScore250Desc;
      case 'score_500':
        return t.medalScore500Desc;
      case 'score_1000':
        return t.medalScore1000Desc;
      case 'games_50':
        return t.medalGames50Desc;
      case 'games_200':
        return t.medalGames200Desc;
      case 'daily_3':
        return t.medalDaily3Desc;
      case 'daily_7':
        return t.medalDaily7Desc;
      case 'near_miss':
        return t.medalNearMissDesc;
      case 'no_collect':
        return t.medalNoCollectDesc;
      case 'coins_100':
        return t.medalCoins100Desc;
      case 'coins_500':
        return t.medalCoins500Desc;
      default:
        return '';
    }
  }
}

class MissionLabels {
  static String title(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'reach_80':
        return t.missionReach80;
      case 'play_5':
        return t.missionPlay5;
      case 'orbs_30':
        return t.missionOrbs30;
      case 'survive_60':
        return t.missionSurvive60;
      case 'reach_120':
        return t.missionReach120;
      default:
        return id;
    }
  }
}

class PerkLabels {
  static String name(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'bigger_magnet':
        return t.perkBiggerMagnetName;
      case 'start_with_shield':
        return t.perkStartWithShieldName;
      case 'richer_coins':
        return t.perkRicherCoinsName;
      default:
        return id;
    }
  }

  static String description(BuildContext context, String id) {
    final t = AppLocalizations.of(context);
    switch (id) {
      case 'bigger_magnet':
        return t.perkBiggerMagnetDesc;
      case 'start_with_shield':
        return t.perkStartWithShieldDesc;
      case 'richer_coins':
        return t.perkRicherCoinsDesc;
      default:
        return '';
    }
  }
}

class SkinUnlockHint {
  static String resolve(BuildContext context, SkinDef skin) {
    final t = AppLocalizations.of(context);
    if (skin.unlockBestScore != null) {
      return t.unlockHintScore(skin.unlockBestScore!);
    }
    if (skin.unlockGamesPlayed != null) {
      return t.unlockHintGames(skin.unlockGamesPlayed!);
    }
    if (skin.unlockDailyStreak != null) {
      return t.unlockHintDaily(skin.unlockDailyStreak!);
    }
    return t.unlocked;
  }
}
