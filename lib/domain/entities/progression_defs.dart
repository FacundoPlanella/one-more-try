class MedalDef {
  const MedalDef({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

class TitleDef {
  const TitleDef({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

enum MissionType {
  reachScore,
  playGames,
  collectOrbs,
  surviveSeconds,
}

class DailyMissionDef {
  const DailyMissionDef({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
  });

  final String id;
  final String title;
  final MissionType type;
  final int target;
}
