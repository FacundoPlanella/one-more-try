import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/generation/difficulty.dart';

void main() {
  group('DifficultyCurve edge cases', () {
    const curve = DifficultyCurve();

    test('clamps negative score to 0 difficulty instead of going negative', () {
      expect(curve.difficultyForScore(-500), 0);
    });

    test('never exceeds 1 even for an enormous score', () {
      expect(curve.difficultyForScore(1e9), 1);
    });

    test('difficulty is monotonically non-decreasing with score', () {
      var previous = curve.difficultyForScore(0);
      for (var score = 0.0; score <= 3000; score += 50) {
        final d = curve.difficultyForScore(score);
        expect(d, greaterThanOrEqualTo(previous));
        previous = d;
      }
    });

    test('gapSeconds shrinks as difficulty rises (harder = tighter gaps)', () {
      expect(curve.gapSeconds(1), lessThan(curve.gapSeconds(0)));
      expect(curve.gapSeconds(0), curve.gapSeconds(0.0));
    });

    test('gapSeconds stays within [minGapSeconds, maxGapSeconds] across the range', () {
      for (var d = 0.0; d <= 1.0; d += 0.05) {
        final gap = curve.gapSeconds(d);
        expect(gap, greaterThanOrEqualTo(0.85 - 1e-9));
        expect(gap, lessThanOrEqualTo(2.4 + 1e-9));
      }
    });

    test('doubleBlockRate and orbChance stay within [0, 1]', () {
      for (var d = 0.0; d <= 1.0; d += 0.1) {
        expect(curve.doubleBlockRate(d), inInclusiveRange(0.0, 1.0));
        expect(curve.orbChance(d), inInclusiveRange(0.0, 1.0));
      }
    });

    test('patternTier clamps to [0, numTiers - 1] at the extremes', () {
      expect(curve.patternTier(0, 5), 0);
      expect(curve.patternTier(1, 5), 4);
      expect(curve.patternTier(0.999999, 5), lessThanOrEqualTo(4));
    });

    test('scrollSpeed at d=0 and d=1 matches the configured base/max bounds', () {
      expect(curve.scrollSpeed(0), 220);
      expect(curve.scrollSpeed(1), 520);
    });
  });
}
