import 'dart:convert';

/// Modelo de guardado local versionado.
class SaveData {
  SaveData({
    this.version = 1,
    this.bestScore = 0,
    this.totalGames = 0,
    this.totalPlayTimeSec = 0,
    this.totalOrbs = 0,
    List<String>? unlockedSkins,
    this.equippedSkin = 'default',
    List<String>? medals,
    this.titleId = 'novato',
    List<int>? deathsPerLane,
    List<int>? recentScores,
    this.nearMissCount = 0,
    this.bestBeatenCount = 0,
    this.daysPlayedCount = 0,
    this.lastPlayedDay = '',
    this.dailyMissionsCompleted = 0,
    this.dailyDate = '',
    this.dailyMissionId = '',
    this.dailyProgress = 0,
    this.dailyCompleted = false,
    this.music = true,
    this.sfx = true,
    this.themeMode = 'dark',
    this.reduceMotion = false,
    this.haptics = true,
    this.tutorialDone = false,
  })  : unlockedSkins = unlockedSkins ?? ['default'],
        medals = medals ?? [],
        deathsPerLane = deathsPerLane ?? [0, 0, 0],
        recentScores = recentScores ?? [];

  int version;
  int bestScore;
  int totalGames;
  double totalPlayTimeSec;
  int totalOrbs;
  List<String> unlockedSkins;
  String equippedSkin;
  List<String> medals;
  String titleId;
  List<int> deathsPerLane;
  List<int> recentScores;
  int nearMissCount;
  int bestBeatenCount;
  int daysPlayedCount;
  String lastPlayedDay;
  int dailyMissionsCompleted;
  String dailyDate;
  String dailyMissionId;
  int dailyProgress;
  bool dailyCompleted;
  bool music;
  bool sfx;
  String themeMode;
  bool reduceMotion;
  bool haptics;
  bool tutorialDone;

  double get averageScore20 {
    if (recentScores.isEmpty) return 0;
    final sum = recentScores.fold<int>(0, (a, b) => a + b);
    return sum / recentScores.length;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'bestScore': bestScore,
        'totalGames': totalGames,
        'totalPlayTimeSec': totalPlayTimeSec,
        'totalOrbs': totalOrbs,
        'unlockedSkins': unlockedSkins,
        'equippedSkin': equippedSkin,
        'medals': medals,
        'titleId': titleId,
        'deathsPerLane': deathsPerLane,
        'recentScores': recentScores,
        'nearMissCount': nearMissCount,
        'bestBeatenCount': bestBeatenCount,
        'daysPlayedCount': daysPlayedCount,
        'lastPlayedDay': lastPlayedDay,
        'dailyMissionsCompleted': dailyMissionsCompleted,
        'dailyDate': dailyDate,
        'dailyMissionId': dailyMissionId,
        'dailyProgress': dailyProgress,
        'dailyCompleted': dailyCompleted,
        'music': music,
        'sfx': sfx,
        'themeMode': themeMode,
        'reduceMotion': reduceMotion,
        'haptics': haptics,
        'tutorialDone': tutorialDone,
      };

  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      version: json['version'] as int? ?? 1,
      bestScore: json['bestScore'] as int? ?? 0,
      totalGames: json['totalGames'] as int? ?? 0,
      totalPlayTimeSec: (json['totalPlayTimeSec'] as num?)?.toDouble() ?? 0,
      totalOrbs: json['totalOrbs'] as int? ?? 0,
      unlockedSkins: (json['unlockedSkins'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['default'],
      equippedSkin: json['equippedSkin'] as String? ?? 'default',
      medals:
          (json['medals'] as List?)?.map((e) => e.toString()).toList() ?? [],
      titleId: json['titleId'] as String? ?? 'novato',
      deathsPerLane: (json['deathsPerLane'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0, 0, 0],
      recentScores: (json['recentScores'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      nearMissCount: json['nearMissCount'] as int? ?? 0,
      bestBeatenCount: json['bestBeatenCount'] as int? ?? 0,
      daysPlayedCount: json['daysPlayedCount'] as int? ?? 0,
      lastPlayedDay: json['lastPlayedDay'] as String? ?? '',
      dailyMissionsCompleted: json['dailyMissionsCompleted'] as int? ?? 0,
      dailyDate: json['dailyDate'] as String? ?? '',
      dailyMissionId: json['dailyMissionId'] as String? ?? '',
      dailyProgress: json['dailyProgress'] as int? ?? 0,
      dailyCompleted: json['dailyCompleted'] as bool? ?? false,
      music: json['music'] as bool? ?? true,
      sfx: json['sfx'] as bool? ?? true,
      themeMode: json['themeMode'] as String? ?? 'dark',
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      haptics: json['haptics'] as bool? ?? true,
      tutorialDone: json['tutorialDone'] as bool? ?? false,
    );
  }

  String encode() => jsonEncode(toJson());

  factory SaveData.decode(String raw) =>
      SaveData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
