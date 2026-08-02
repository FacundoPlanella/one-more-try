import '../catalogs/progression_catalogs.dart';
import '../catalogs/skin_catalog.dart';
import '../entities/progression_defs.dart';
import '../../data/save_data.dart';

class RunResult {
  const RunResult({
    required this.score,
    required this.durationSec,
    required this.orbsCollected,
    required this.coinsCollected,
    required this.deathLane,
    required this.collectedAnyOrb,
  });

  final int score;
  final double durationSec;
  final int orbsCollected;
  final int coinsCollected;
  final int deathLane;
  final bool collectedAnyOrb;
}

class ProgressionApplyResult {
  const ProgressionApplyResult({
    required this.newBest,
    required this.newMedals,
    required this.newSkins,
    required this.newTitle,
    required this.dailyJustCompleted,
  });

  final bool newBest;
  final List<String> newMedals;
  final List<String> newSkins;
  final String? newTitle;
  final bool dailyJustCompleted;
}

/// Aplica progreso offline tras cada partida.
class ProgressionService {
  ProgressionApplyResult applyRun(SaveData save, RunResult run) {
    final newMedals = <String>[];
    final newSkins = <String>[];
    String? newTitle;
    var newBest = false;
    var dailyJustCompleted = false;

    final previousBest = save.bestScore;
    save.totalGames += 1;
    save.totalPlayTimeSec += run.durationSec;
    save.totalOrbs += run.orbsCollected;
    save.coins += run.coinsCollected;
    save.totalCoinsEarned += run.coinsCollected;
    if (run.deathLane >= 0 && run.deathLane < save.deathsPerLane.length) {
      save.deathsPerLane[run.deathLane] += 1;
    }
    save.recentScores.add(run.score);
    if (save.recentScores.length > 20) {
      save.recentScores.removeAt(0);
    }

    if (run.score > save.bestScore) {
      save.bestScore = run.score;
      save.bestBeatenCount += 1;
      newBest = true;
    } else if (previousBest > 0 && (previousBest - run.score) <= 10) {
      save.nearMissCount += 1;
    }

    _trackPlayDay(save);
    _refreshDailyIfNeeded(save);
    dailyJustCompleted = _updateDaily(save, run);

    _unlockSkins(save, newSkins);
    _unlockMedals(save, run, newMedals);
    newTitle = _updateTitle(save);

    save.tutorialDone = true;
    return ProgressionApplyResult(
      newBest: newBest,
      newMedals: newMedals,
      newSkins: newSkins,
      newTitle: newTitle,
      dailyJustCompleted: dailyJustCompleted,
    );
  }

  void ensureDaily(SaveData save) => _refreshDailyIfNeeded(save);

  void _trackPlayDay(SaveData save) {
    final today = _dayKey(DateTime.now());
    if (save.lastPlayedDay != today) {
      save.daysPlayedCount += 1;
      save.lastPlayedDay = today;
    }
  }

  void _refreshDailyIfNeeded(SaveData save) {
    final today = _dayKey(DateTime.now());
    if (save.dailyDate == today && save.dailyMissionId.isNotEmpty) return;
    final mission = MissionCatalog.forDate(DateTime.now());
    save.dailyDate = today;
    save.dailyMissionId = mission.id;
    save.dailyProgress = 0;
    save.dailyCompleted = false;
  }

  bool _updateDaily(SaveData save, RunResult run) {
    if (save.dailyCompleted) return false;
    final mission = MissionCatalog.pool.firstWhere(
      (m) => m.id == save.dailyMissionId,
      orElse: () => MissionCatalog.forDate(DateTime.now()),
    );

    switch (mission.type) {
      case MissionType.reachScore:
        if (run.score > save.dailyProgress) {
          save.dailyProgress = run.score;
        }
      case MissionType.playGames:
        save.dailyProgress += 1;
      case MissionType.collectOrbs:
        save.dailyProgress += run.orbsCollected;
      case MissionType.surviveSeconds:
        final secs = run.durationSec.floor();
        if (secs > save.dailyProgress) save.dailyProgress = secs;
    }

    if (save.dailyProgress >= mission.target) {
      save.dailyProgress = mission.target;
      save.dailyCompleted = true;
      save.dailyMissionsCompleted += 1;
      return true;
    }
    return false;
  }

  void _unlockSkins(SaveData save, List<String> newly) {
    for (final skin in SkinCatalog.all) {
      if (save.unlockedSkins.contains(skin.id)) continue;
      final unlocked = SkinCatalog.isUnlocked(
        skin,
        bestScore: save.bestScore,
        gamesPlayed: save.totalGames,
        dailyMissionsCompleted: save.dailyMissionsCompleted,
      );
      if (unlocked) {
        save.unlockedSkins.add(skin.id);
        newly.add(skin.id);
      }
    }
  }

  void _unlockMedals(SaveData save, RunResult run, List<String> newly) {
    void grant(String id) {
      if (!save.medals.contains(id)) {
        save.medals.add(id);
        newly.add(id);
      }
    }

    grant('first_run');
    if (run.score >= 50 || save.bestScore >= 50) grant('score_50');
    if (run.score >= 100 || save.bestScore >= 100) grant('score_100');
    if (run.score >= 250 || save.bestScore >= 250) grant('score_250');
    if (run.score >= 500 || save.bestScore >= 500) grant('score_500');
    if (run.score >= 1000 || save.bestScore >= 1000) grant('score_1000');
    if (save.totalGames >= 50) grant('games_50');
    if (save.totalGames >= 200) grant('games_200');
    if (save.dailyMissionsCompleted >= 3) grant('daily_3');
    if (save.dailyMissionsCompleted >= 7) grant('daily_7');
    if (save.nearMissCount >= 10) grant('near_miss');
    if (run.score >= 150 && !run.collectedAnyOrb) grant('no_collect');
    if (save.totalCoinsEarned >= 10000) grant('coins_100');
    if (save.totalCoinsEarned >= 50000) grant('coins_500');
  }

  String? _updateTitle(SaveData save) {
    String pick = 'novato';
    if (save.bestScore >= 50) pick = 'aprendiz';
    if (save.daysPlayedCount >= 7) pick = 'constante';
    if (save.bestBeatenCount >= 10) pick = 'cazador';
    if (save.unlockedSkins.length >= 5) pick = 'minimalista';
    if (save.totalGames >= 500) pick = 'uno_mas';
    if (save.bestScore >= 750) pick = 'equilibrio';
    if (save.bestScore >= 1500) pick = 'one_more_try';

    if (pick != save.titleId) {
      save.titleId = pick;
      return pick;
    }
    return null;
  }

  static String _dayKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static DailyMissionDef currentMission(SaveData save) {
    return MissionCatalog.pool.firstWhere(
      (m) => m.id == save.dailyMissionId,
      orElse: () => MissionCatalog.forDate(DateTime.now()),
    );
  }
}
