import 'dart:math' as math;

import '../core/constants/game_constants.dart';

/// Mapea score → parámetros de dificultad.
/// Tunear solo aquí para balancear sin tocar el gameplay.
class DifficultyCurve {
  const DifficultyCurve();

  double difficultyForScore(double score) {
    final d = 1 - math.exp(-score / GameConstants.difficultyScoreScale);
    return d.clamp(0.0, 1.0);
  }

  double scrollSpeed(double d) => _lerp(
        GameConstants.baseScrollSpeed,
        GameConstants.maxScrollSpeed,
        _smoothstep(d),
      );

  double gapSeconds(double d) => _lerp(
        GameConstants.maxGapSeconds,
        GameConstants.minGapSeconds,
        d,
      );

  double doubleBlockRate(double d) =>
      _lerp(0.05, 0.55, math.pow(d, 1.2).toDouble());

  double orbChance(double d) => _lerp(0.35, 0.20, d);

  int patternTier(double d, int numTiers) =>
      (d * numTiers).floor().clamp(0, numTiers - 1);

  double breathEvery(double d) => _lerp(
        GameConstants.breathEveryEasy,
        GameConstants.breathEveryHard,
        d,
      );

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _smoothstep(double x) {
    final t = x.clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }
}
