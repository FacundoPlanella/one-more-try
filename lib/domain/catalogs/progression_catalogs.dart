import '../entities/progression_defs.dart';

class MedalCatalog {
  MedalCatalog._();

  static const List<MedalDef> all = [
    MedalDef(
      id: 'first_run',
      name: 'First pulse',
      description: 'Finish 1 game',
    ),
    MedalDef(
      id: 'score_50',
      name: 'Awakening',
      description: 'Score ≥ 50',
    ),
    MedalDef(
      id: 'score_100',
      name: 'In rhythm',
      description: 'Score ≥ 100',
    ),
    MedalDef(
      id: 'score_250',
      name: 'Focus',
      description: 'Score ≥ 250',
    ),
    MedalDef(
      id: 'score_500',
      name: 'Master',
      description: 'Score ≥ 500',
    ),
    MedalDef(
      id: 'score_1000',
      name: 'Legend',
      description: 'Score ≥ 1000',
    ),
    MedalDef(
      id: 'games_50',
      name: 'Persistent',
      description: 'Play 50 games',
    ),
    MedalDef(
      id: 'games_200',
      name: 'Habitual',
      description: 'Play 200 games',
    ),
    MedalDef(
      id: 'daily_3',
      name: 'Consistency',
      description: 'Complete 3 daily missions',
    ),
    MedalDef(
      id: 'daily_7',
      name: 'Perfect week',
      description: 'Complete 7 daily missions',
    ),
    MedalDef(
      id: 'near_miss',
      name: 'Almost…',
      description: '10 games within 10 of your best',
    ),
    MedalDef(
      id: 'no_collect',
      name: 'Purist',
      description: 'Score ≥ 150 without orbs',
    ),
    MedalDef(
      id: 'coins_100',
      name: 'Coin pouch',
      description: 'Earn 10,000 coins total',
    ),
    MedalDef(
      id: 'coins_500',
      name: 'Treasury',
      description: 'Earn 50,000 coins total',
    ),
  ];
}

class TitleCatalog {
  TitleCatalog._();

  static const List<TitleDef> all = [
    TitleDef(id: 'novato', name: 'Novice', description: 'Default'),
    TitleDef(id: 'aprendiz', name: 'Apprentice', description: 'Best ≥ 50'),
    TitleDef(
      id: 'constante',
      name: 'Steady',
      description: 'Play on 7 different days',
    ),
    TitleDef(
      id: 'cazador',
      name: 'Record hunter',
      description: 'Beat your best 10 times',
    ),
    TitleDef(
      id: 'minimalista',
      name: 'Minimalist',
      description: 'Unlock 5 skins',
    ),
    TitleDef(
      id: 'uno_mas',
      name: 'One more',
      description: '500 games played',
    ),
    TitleDef(id: 'equilibrio', name: 'Balance', description: 'Best ≥ 750'),
    TitleDef(
      id: 'one_more_try',
      name: 'One more try.',
      description: 'Best ≥ 1500',
    ),
  ];
}

class MissionCatalog {
  MissionCatalog._();

  static const List<DailyMissionDef> pool = [
    DailyMissionDef(
      id: 'reach_80',
      title: 'Reach 80 in one run',
      type: MissionType.reachScore,
      target: 80,
    ),
    DailyMissionDef(
      id: 'play_5',
      title: 'Play 5 games',
      type: MissionType.playGames,
      target: 5,
    ),
    DailyMissionDef(
      id: 'orbs_30',
      title: 'Collect 30 orbs',
      type: MissionType.collectOrbs,
      target: 30,
    ),
    DailyMissionDef(
      id: 'survive_60',
      title: 'Survive 60 seconds',
      type: MissionType.surviveSeconds,
      target: 60,
    ),
    DailyMissionDef(
      id: 'reach_120',
      title: 'Reach 120 in one run',
      type: MissionType.reachScore,
      target: 120,
    ),
  ];

  /// Misión determinista por fecha local (offline, sin servidor).
  static DailyMissionDef forDate(DateTime date) {
    final key = date.year * 10000 + date.month * 100 + date.day;
    return pool[key % pool.length];
  }
}
