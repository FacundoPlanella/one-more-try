import 'dart:math';

import '../core/constants/game_constants.dart';
import 'difficulty.dart';
import 'patterns.dart';
import 'segment.dart';

/// Genera segmentos infinitos con path validation lateral.
class SegmentGenerator {
  SegmentGenerator({
    required this.runSeed,
    this.curve = const DifficultyCurve(),
  }) : _rng = Random(runSeed);

  final int runSeed;
  final DifficultyCurve curve;
  final Random _rng;

  int _index = 0;
  int _lastMask = 0;
  int _sinceBreath = 0;
  int _simulatedLane = 1;

  /// Tiempo mínimo estimado para cruzar un carril (segundos).
  static const double _laneSwitchTime = GameConstants.laneSwitchDuration + 0.02;

  Segment next(double score) {
    final d = curve.difficultyForScore(score);
    final speed = curve.scrollSpeed(d);
    final gap = curve.gapSeconds(d);
    final tier = _index < GameConstants.warmupSegments
        ? 0
        : curve.patternTier(d, 5);
    final breathEvery = curve.breathEvery(d);

    _sinceBreath++;
    if (_sinceBreath >= breathEvery.round() && _index > GameConstants.warmupSegments) {
      _sinceBreath = 0;
      _index++;
      // Respiración: sin obstáculo, posible orbe.
      final orbLane = _simulatedLane;
      return Segment(
        obstacleMask: 0,
        hasOrb: _rng.nextBool(),
        orbLane: orbLane,
        isBreath: true,
      );
    }

    var mask = PatternLibrary.pickMask(
      rng: _rng,
      tier: tier,
      doubleRate: curve.doubleBlockRate(d),
      previousMask: _lastMask,
      playerLaneHint: _simulatedLane,
    );

    mask = _ensureReachable(
      mask: mask,
      fromLane: _simulatedLane,
      gapSeconds: gap,
      scrollSpeed: speed,
    );

    _lastMask = mask;
    final free = LaneMask.freeLaneIndices(mask);
    // Elige el carril libre más cercano para simular path del jugador.
    _simulatedLane = free.reduce(
      (a, b) => (a - _simulatedLane).abs() <= (b - _simulatedLane).abs() ? a : b,
    );

    final hasOrb =
        free.isNotEmpty && _rng.nextDouble() < curve.orbChance(d);
    final orbLane = hasOrb ? free[_rng.nextInt(free.length)] : 1;

    _index++;
    return Segment(
      obstacleMask: mask,
      hasOrb: hasOrb,
      orbLane: orbLane,
    );
  }

  /// Garantiza que exista un carril libre alcanzable a tiempo.
  int _ensureReachable({
    required int mask,
    required int fromLane,
    required double gapSeconds,
    required double scrollSpeed,
  }) {
    var current = mask;
    if (current == LaneMask.all) {
      current = LaneMask.all & ~(1 << fromLane);
    }

    final maxLaneDelta = max(
      1,
      (gapSeconds / _laneSwitchTime).floor(),
    );

    bool reachable(int m) {
      final free = LaneMask.freeLaneIndices(m);
      return free.any((lane) => (lane - fromLane).abs() <= maxLaneDelta);
    }

    if (reachable(current)) return current;

    // Abre el carril actual o el más cercano.
    current = current & ~(1 << fromLane);
    if (current == LaneMask.all) {
      current = 0;
    }
    if (!reachable(current)) {
      current = 0; // fail-safe: open
    }
    return current;
  }
}
