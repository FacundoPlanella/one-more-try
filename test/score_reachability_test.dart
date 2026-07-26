import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/constants/game_constants.dart';
import 'package:one_more_try/domain/catalogs/skin_catalog.dart';
import 'package:one_more_try/generation/difficulty.dart';
import 'package:one_more_try/generation/segment.dart';
import 'package:one_more_try/generation/segment_generator.dart';

/// Simula un jugador perfecto que siempre se mueve al carril libre más cercano.
class PerfectRunSimulator {
  PerfectRunSimulator({required this.seed})
      : generator = SegmentGenerator(runSeed: seed);

  final int seed;
  final SegmentGenerator generator;
  final DifficultyCurve curve = const DifficultyCurve();

  double score = 0;
  double elapsed = 0;
  int playerLane = 1;
  int orbsCollected = 0;
  int combo = 0;
  int segments = 0;
  int switches = 0;

  /// Corre hasta [targetScore] o falla si un obstáculo es inalcanzable a tiempo.
  bool runUntil({required double targetScore, int maxSegments = 20000}) {
    while (score < targetScore && segments < maxSegments) {
      final d = curve.difficultyForScore(score);
      final gap = curve.gapSeconds(d);
      final segment = generator.next(score);
      segments++;

      // El tiempo avanza al menos el gap entre filas.
      elapsed += gap;
      score += GameConstants.scorePerSecond * gap;

      if (segment.hasObstacle) {
        final free = LaneMask.freeLaneIndices(segment.obstacleMask);
        expect(
          free,
          isNotEmpty,
          reason: 'seed=$seed score=${score.toStringAsFixed(1)} mask all blocked',
        );

        final target = free.reduce(
          (a, b) =>
              (a - playerLane).abs() <= (b - playerLane).abs() ? a : b,
        );
        final delta = (target - playerLane).abs();
        final switchTime = delta * GameConstants.laneSwitchDuration;

        // Debe alcanzar el carril antes de que la fila llegue (≈ gap).
        if (switchTime > gap + 0.05) {
          return false;
        }

        if (delta > 0) {
          switches += delta;
          playerLane = target;
        }

        if (LaneMask.isBlocked(segment.obstacleMask, playerLane)) {
          return false;
        }
      }

      if (segment.hasOrb && segment.orbLane == playerLane) {
        orbsCollected++;
        combo++;
        score += GameConstants.orbScore.toDouble();
        if (combo % GameConstants.comboEvery == 0) {
          score += 1;
        }
      } else if (segment.hasOrb) {
        // Orbe en otro carril: el jugador perfecto prioriza sobrevivir.
        combo = 0;
      }
    }
    return score >= targetScore;
  }
}

void main() {
  group('Score reachability to 1000', () {
    test('time alone can produce 1000 points (~16.7 min survival)', () {
      // score += 1.0 * dt → 1000 s de vida = 1000 pts mínimos.
      const neededSeconds = 1000.0 / GameConstants.scorePerSecond;
      expect(neededSeconds, 1000);
      expect(neededSeconds / 60, closeTo(16.67, 0.01));
    });

    test('Prism skin is gated behind best score 1000', () {
      final prism = SkinCatalog.byId('prism');
      expect(prism.unlockBestScore, 1000);
      expect(
        SkinCatalog.isUnlocked(
          prism,
          bestScore: 999,
          gamesPlayed: 9999,
          dailyMissionsCompleted: 9999,
        ),
        isFalse,
      );
      expect(
        SkinCatalog.isUnlocked(
          prism,
          bestScore: 1000,
          gamesPlayed: 0,
          dailyMissionsCompleted: 0,
        ),
        isTrue,
      );
    });

    test('difficulty at score 1000 is high but not soft-capped for scoring', () {
      const curve = DifficultyCurve();
      final d = curve.difficultyForScore(1000);
      expect(d, greaterThan(0.95));
      expect(d, lessThanOrEqualTo(1.0));
      // El score sigue creciendo linealmente con el tiempo a cualquier d.
      expect(GameConstants.scorePerSecond, greaterThan(0));
    });

    test('perfect play reaches 1000 on a fixed seed', () {
      final sim = PerfectRunSimulator(seed: 42);
      final ok = sim.runUntil(targetScore: 1000);
      expect(ok, isTrue, reason: 'perfect play should reach 1000');
      expect(sim.score, greaterThanOrEqualTo(1000));
      expect(sim.elapsed, greaterThan(800)); // tiempo de juego realista
      // ignore: avoid_print
      print(
        'seed=42 → score=${sim.score.toStringAsFixed(1)} '
        'elapsed=${sim.elapsed.toStringAsFixed(1)}s '
        'orbs=${sim.orbsCollected} switches=${sim.switches} '
        'segments=${sim.segments}',
      );
    });

    test('perfect play reaches 1000 across many seeds', () {
      final failures = <int>[];
      final samples = <String>[];
      const seedCount = 100;

      for (var seed = 0; seed < seedCount; seed++) {
        final sim = PerfectRunSimulator(seed: seed);
        final ok = sim.runUntil(targetScore: 1000);
        if (!ok) {
          failures.add(seed);
        } else if (samples.length < 5) {
          samples.add(
            'seed=$seed score=${sim.score.toStringAsFixed(0)} '
            't=${(sim.elapsed / 60).toStringAsFixed(1)}m '
            'orbs=${sim.orbsCollected}',
          );
        }
      }

      expect(
        failures,
        isEmpty,
        reason: 'Unreachable runs for seeds: $failures',
      );
      expect(failures.length + samples.length, greaterThan(0));
      // ignore: avoid_print
      print('Passed $seedCount/$seedCount seeds\n${samples.join('\n')}');
    });

    test('generator stays solvable from 0 to 1200 score (path validation)', () {
      final rng = Random(7);
      for (var trial = 0; trial < 15; trial++) {
        final seed = rng.nextInt(1 << 20);
        final gen = SegmentGenerator(runSeed: seed);
        const curve = DifficultyCurve();
        var score = 0.0;
        var lane = 1;

        while (score < 1200) {
          final d = curve.difficultyForScore(score);
          final gap = curve.gapSeconds(d);
          final segment = gen.next(score);
          score += gap;

          if (!segment.hasObstacle) continue;

          final free = LaneMask.freeLaneIndices(segment.obstacleMask);
          expect(free, isNotEmpty, reason: 'seed=$seed at score=$score');

          final maxDelta =
              max(1, (gap / (GameConstants.laneSwitchDuration + 0.02)).floor());
          final reachable =
              free.any((l) => (l - lane).abs() <= maxDelta);
          expect(
            reachable,
            isTrue,
            reason:
                'seed=$seed score=${score.toStringAsFixed(1)} '
                'lane=$lane free=$free maxDelta=$maxDelta',
          );

          lane = free.reduce(
            (a, b) => (a - lane).abs() <= (b - lane).abs() ? a : b,
          );
        }
      }
    });

    test('estimate: orbs reduce time-to-1000 but survival still required', () {
      final sim = PerfectRunSimulator(seed: 123);
      sim.runUntil(targetScore: 1000);
      final orbBonus = sim.orbsCollected; // + combos already in score
      // Sin orbes haría falta ~1000s; con orbes el elapsed debe ser menor.
      expect(sim.elapsed, lessThan(1000));
      expect(sim.orbsCollected, greaterThan(0));
      // ignore: avoid_print
      print(
        'With orbs≈$orbBonus, time to 1000 ≈ '
        '${(sim.elapsed / 60).toStringAsFixed(1)} minutes',
      );
    });
  });
}
