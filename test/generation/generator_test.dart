import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/generation/difficulty.dart';
import 'package:one_more_try/generation/segment.dart';
import 'package:one_more_try/generation/segment_generator.dart';

void main() {
  group('DifficultyCurve', () {
    const curve = DifficultyCurve();

    test('starts near zero and grows toward 1', () {
      expect(curve.difficultyForScore(0), closeTo(0, 0.01));
      expect(curve.difficultyForScore(180), greaterThan(0.5));
      expect(curve.difficultyForScore(2000), closeTo(1, 0.05));
    });

    test('scroll speed increases with difficulty', () {
      final slow = curve.scrollSpeed(0);
      final fast = curve.scrollSpeed(1);
      expect(fast, greaterThan(slow));
    });
  });

  group('SegmentGenerator', () {
    test('never blocks all lanes', () {
      final gen = SegmentGenerator(runSeed: 42);
      for (var i = 0; i < 200; i++) {
        final segment = gen.next(i * 3.0);
        expect(segment.obstacleMask & LaneMask.all, isNot(LaneMask.all));
        if (segment.hasOrb) {
          expect(LaneMask.isBlocked(segment.obstacleMask, segment.orbLane), isFalse);
        }
      }
    });

    test('same seed is deterministic for first segments', () {
      final a = SegmentGenerator(runSeed: 99);
      final b = SegmentGenerator(runSeed: 99);
      final masksA = List.generate(30, (i) => a.next(i * 2.0).obstacleMask);
      final masksB = List.generate(30, (i) => b.next(i * 2.0).obstacleMask);
      expect(masksA, masksB);
    });
  });
}
