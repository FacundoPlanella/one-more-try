import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/data/save_data.dart';
import 'package:one_more_try/domain/catalogs/progression_catalogs.dart';
import 'package:one_more_try/domain/progression/progression_service.dart';

RunResult _run({
  int score = 0,
  double durationSec = 0,
  int orbsCollected = 0,
  int coinsCollected = 0,
  int deathLane = -1,
  bool collectedAnyOrb = false,
}) =>
    RunResult(
      score: score,
      durationSec: durationSec,
      orbsCollected: orbsCollected,
      coinsCollected: coinsCollected,
      deathLane: deathLane,
      collectedAnyOrb: collectedAnyOrb,
    );

void main() {
  late ProgressionService service;
  late SaveData save;

  setUp(() {
    service = ProgressionService();
    save = SaveData();
  });

  group('basic run accounting', () {
    test('accumulates games, playtime, orbs and coins', () {
      service.applyRun(
        save,
        _run(
          score: 30,
          durationSec: 45.5,
          orbsCollected: 3,
          coinsCollected: 2,
        ),
      );
      expect(save.totalGames, 1);
      expect(save.totalPlayTimeSec, 45.5);
      expect(save.totalOrbs, 3);
      expect(save.coins, 2);
      expect(save.totalCoinsEarned, 2);
      expect(save.tutorialDone, isTrue);
    });

    test('tracks deaths per lane at the given index', () {
      service.applyRun(save, _run(score: 10, deathLane: 2));
      expect(save.deathsPerLane, [0, 0, 1]);
    });

    test('ignores out-of-range death lane without throwing', () {
      expect(() => service.applyRun(save, _run(score: 10, deathLane: -1)),
          returnsNormally);
      expect(save.deathsPerLane, [0, 0, 0]);
    });

    test('recentScores keeps at most the last 20 entries (FIFO)', () {
      for (var i = 1; i <= 25; i++) {
        service.applyRun(save, _run(score: i));
      }
      expect(save.recentScores.length, 20);
      // El primero conservado debe ser el run #6 (se descartaron 1..5).
      expect(save.recentScores.first, 6);
      expect(save.recentScores.last, 25);
    });
  });

  group('best score and near misses', () {
    test('first run always sets a new best', () {
      final result = service.applyRun(save, _run(score: 42));
      expect(result.newBest, isTrue);
      expect(save.bestScore, 42);
      expect(save.bestBeatenCount, 1);
    });

    test('a lower score does not beat the best and does not error', () {
      service.applyRun(save, _run(score: 100));
      final result = service.applyRun(save, _run(score: 50));
      expect(result.newBest, isFalse);
      expect(save.bestScore, 100);
      expect(save.bestBeatenCount, 1);
    });

    test('scoring within 10 points of the previous best counts as near miss', () {
      service.applyRun(save, _run(score: 100));
      service.applyRun(save, _run(score: 95)); // 100 - 95 = 5 <= 10
      expect(save.nearMissCount, 1);
    });

    test('scoring more than 10 points below best is not a near miss', () {
      service.applyRun(save, _run(score: 100));
      service.applyRun(save, _run(score: 80)); // gap of 20
      expect(save.nearMissCount, 0);
    });

    test('beating the best is not also counted as a near miss', () {
      service.applyRun(save, _run(score: 100));
      service.applyRun(save, _run(score: 105));
      expect(save.nearMissCount, 0);
      expect(save.bestBeatenCount, 2);
    });
  });

  group('medals', () {
    test('grants first_run on the very first game', () {
      final result = service.applyRun(save, _run(score: 1));
      expect(result.newMedals, contains('first_run'));
      expect(save.medals, contains('first_run'));
    });

    test('does not re-grant an already-owned medal', () {
      service.applyRun(save, _run(score: 60));
      final result = service.applyRun(save, _run(score: 60));
      expect(result.newMedals, isEmpty);
    });

    test('score medals unlock at their thresholds', () {
      final result = service.applyRun(save, _run(score: 1000));
      for (final id in [
        'score_50',
        'score_100',
        'score_250',
        'score_500',
        'score_1000',
      ]) {
        expect(result.newMedals, contains(id));
      }
    });

    test('score medal unlocks from a previous best even on a worse run', () {
      service.applyRun(save, _run(score: 500));
      // Nueva partida floja, pero save.bestScore ya es 500.
      final result = service.applyRun(save, _run(score: 10));
      expect(result.newMedals, isNot(contains('score_500')));
      expect(save.medals, contains('score_500'));
    });

    test('games_50 unlocks after 50 games played', () {
      for (var i = 0; i < 49; i++) {
        service.applyRun(save, _run(score: 1));
      }
      expect(save.medals, isNot(contains('games_50')));
      final result = service.applyRun(save, _run(score: 1));
      expect(result.newMedals, contains('games_50'));
    });

    test('no_collect requires score >= 150 and zero orbs collected', () {
      final withOrb =
          service.applyRun(save, _run(score: 200, collectedAnyOrb: true));
      expect(withOrb.newMedals, isNot(contains('no_collect')));

      final save2 = SaveData();
      final withoutOrb = service.applyRun(
        save2,
        _run(score: 200, collectedAnyOrb: false),
      );
      expect(withoutOrb.newMedals, contains('no_collect'));

      final save3 = SaveData();
      final tooLow = service.applyRun(
        save3,
        _run(score: 100, collectedAnyOrb: false),
      );
      expect(tooLow.newMedals, isNot(contains('no_collect')));
    });

    test('coins_100 and coins_500 accumulate across runs', () {
      final r1 =
          service.applyRun(save, _run(score: 1, coinsCollected: 9999));
      expect(r1.newMedals, isNot(contains('coins_100')));
      final r2 = service.applyRun(save, _run(score: 1, coinsCollected: 1));
      expect(r2.newMedals, contains('coins_100'));
      expect(r2.newMedals, isNot(contains('coins_500')));
    });

    test('near_miss medal needs 10 near-miss runs', () {
      service.applyRun(save, _run(score: 100));
      ProgressionApplyResult? last;
      for (var i = 0; i < 10; i++) {
        last = service.applyRun(save, _run(score: 95));
      }
      expect(save.nearMissCount, 10);
      expect(last!.newMedals, contains('near_miss'));
    });
  });

  group('skin unlocks', () {
    test('unlocks skins gated by best score as it increases', () {
      final result = service.applyRun(save, _run(score: 50));
      expect(result.newSkins, contains('ember'));
      expect(save.unlockedSkins, contains('ember'));
    });

    test('never auto-unlocks shop-exclusive skins from progress', () {
      final result = service.applyRun(save, _run(score: 100000));
      expect(result.newSkins, isNot(contains('shop_diwata')));
      expect(save.unlockedSkins, isNot(contains('shop_diwata')));
    });

    test('does not re-unlock a skin already owned', () {
      service.applyRun(save, _run(score: 50));
      final result = service.applyRun(save, _run(score: 60));
      expect(result.newSkins, isEmpty);
    });
  });

  group('titles', () {
    test('stays novato with no progress', () {
      final result = service.applyRun(save, _run(score: 1));
      expect(result.newTitle, isNull);
      expect(save.titleId, 'novato');
    });

    test('progresses to aprendiz at best score 50 and reports the change', () {
      final result = service.applyRun(save, _run(score: 50));
      expect(result.newTitle, 'aprendiz');
      expect(save.titleId, 'aprendiz');
    });

    test('returns null when the picked title does not change', () {
      service.applyRun(save, _run(score: 50));
      final result = service.applyRun(save, _run(score: 55));
      expect(result.newTitle, isNull);
    });

    test('picks the highest-priority matching title (best score 1500)', () {
      final result = service.applyRun(save, _run(score: 1500));
      expect(save.titleId, 'one_more_try');
      expect(result.newTitle, 'one_more_try');
    });
  });

  group('daily mission progress', () {
    test('ensureDaily assigns a mission deterministically for today', () {
      service.ensureDaily(save);
      final expected = MissionCatalog.forDate(DateTime.now());
      expect(save.dailyMissionId, expected.id);
      expect(save.dailyCompleted, isFalse);
      expect(save.dailyProgress, 0);
    });

    test('reachScore mission tracks the best score seen, not a sum', () {
      save.dailyMissionId = 'reach_80';
      save.dailyDate = _todayKey();
      service.applyRun(save, _run(score: 30));
      expect(save.dailyProgress, 30);
      service.applyRun(save, _run(score: 20));
      expect(save.dailyProgress, 30); // no retrocede
      service.applyRun(save, _run(score: 90));
      expect(save.dailyProgress, 80); // clamped al target
      expect(save.dailyCompleted, isTrue);
    });

    test('playGames mission increments by one per run', () {
      save.dailyMissionId = 'play_5';
      save.dailyDate = _todayKey();
      for (var i = 0; i < 4; i++) {
        final r = service.applyRun(save, _run(score: 1));
        expect(r.dailyJustCompleted, isFalse);
      }
      expect(save.dailyProgress, 4);
      final last = service.applyRun(save, _run(score: 1));
      expect(save.dailyProgress, 5);
      expect(save.dailyCompleted, isTrue);
      expect(last.dailyJustCompleted, isTrue);
      expect(save.dailyMissionsCompleted, 1);
    });

    test('collectOrbs mission sums orbs across runs', () {
      save.dailyMissionId = 'orbs_30';
      save.dailyDate = _todayKey();
      service.applyRun(save, _run(score: 1, orbsCollected: 10));
      service.applyRun(save, _run(score: 1, orbsCollected: 15));
      expect(save.dailyProgress, 25);
      final result = service.applyRun(save, _run(score: 1, orbsCollected: 10));
      expect(save.dailyProgress, 30);
      expect(result.dailyJustCompleted, isTrue);
    });

    test('surviveSeconds mission tracks the max duration, not a sum', () {
      save.dailyMissionId = 'survive_60';
      save.dailyDate = _todayKey();
      service.applyRun(save, _run(score: 1, durationSec: 20));
      expect(save.dailyProgress, 20);
      service.applyRun(save, _run(score: 1, durationSec: 15));
      expect(save.dailyProgress, 20); // no retrocede
      final result =
          service.applyRun(save, _run(score: 1, durationSec: 61.9));
      expect(save.dailyProgress, 60); // floor + clamp
      expect(result.dailyJustCompleted, isTrue);
    });

    test('does not report completion again once already completed', () {
      save.dailyMissionId = 'play_5';
      save.dailyDate = _todayKey();
      for (var i = 0; i < 5; i++) {
        service.applyRun(save, _run(score: 1));
      }
      expect(save.dailyCompleted, isTrue);
      final again = service.applyRun(save, _run(score: 1));
      expect(again.dailyJustCompleted, isFalse);
      expect(save.dailyMissionsCompleted, 1);
    });

    test('unknown dailyMissionId falls back to today\'s catalog mission', () {
      save.dailyMissionId = 'not_a_real_id';
      save.dailyDate = _todayKey();
      expect(() => service.applyRun(save, _run(score: 1)), returnsNormally);
    });
  });
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
