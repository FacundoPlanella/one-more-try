import 'dart:math';

import 'segment.dart';

/// Plantillas procedurales por tier de dificultad.
class PatternLibrary {
  PatternLibrary._();

  /// Devuelve una máscara de obstáculo válida (nunca bloquea los 3 carriles).
  static int pickMask({
    required Random rng,
    required int tier,
    required double doubleRate,
    required int previousMask,
    required int playerLaneHint,
  }) {
    // Warm / easy: single block
    if (tier <= 0) {
      return _single(rng, avoidLane: null);
    }

    if (tier == 1) {
      return rng.nextDouble() < doubleRate
          ? _double(rng, preferOpen: playerLaneHint)
          : _single(rng);
    }

    if (tier == 2) {
      // Alternating bias away from previous free lanes
      if (rng.nextDouble() < 0.45) {
        return _alternate(previousMask, rng);
      }
      return rng.nextDouble() < doubleRate
          ? _double(rng, preferOpen: playerLaneHint)
          : _single(rng);
    }

    if (tier >= 3) {
      if (rng.nextDouble() < 0.25) {
        return _forceZigzag(playerLaneHint, rng);
      }
      if (rng.nextDouble() < 0.2) {
        return _fakeOpen(rng);
      }
      return rng.nextDouble() < doubleRate
          ? _double(rng, preferOpen: (playerLaneHint + 1) % 3)
          : _single(rng);
    }

    return _single(rng);
  }

  static int _single(Random rng, {int? avoidLane}) {
    var lane = rng.nextInt(3);
    if (avoidLane != null && lane == avoidLane) {
      lane = (lane + 1 + rng.nextInt(2)) % 3;
    }
    return 1 << lane;
  }

  static int _double(Random rng, {required int preferOpen}) {
    final open = preferOpen.clamp(0, 2);
    return LaneMask.all & ~(1 << open);
  }

  static int _alternate(int previousMask, Random rng) {
    final free = LaneMask.freeLaneIndices(previousMask);
    if (free.isEmpty) return _single(rng);
    // Block previous free lanes when possible (force move)
    var mask = 0;
    for (final lane in free) {
      mask |= 1 << lane;
    }
    if (mask == LaneMask.all) {
      mask = LaneMask.all & ~(1 << free.first);
    }
    return mask;
  }

  static int _forceZigzag(int playerLane, Random rng) {
    // Block current + one adjacent → force a decisive move
    final other = (playerLane + (rng.nextBool() ? 1 : 2)) % 3;
    var mask = (1 << playerLane) | (1 << other);
    if (mask == LaneMask.all) mask = 1 << playerLane;
    return mask;
  }

  static int _fakeOpen(Random rng) {
    // Often open center then… handled across segments; here block sides.
    return LaneMask.left | LaneMask.right;
  }
}
