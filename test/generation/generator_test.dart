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
        if (segment.hasPickup) {
          expect(
            LaneMask.isBlocked(segment.obstacleMask, segment.pickupLane),
            isFalse,
          );
        }
        for (final lane in segment.coinLanes) {
          expect(LaneMask.isBlocked(segment.obstacleMask, lane), isFalse);
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

    test('coin trail rows sometimes cluster more than one coin per row', () {
      final gen = SegmentGenerator(runSeed: 7);
      var sawTwoOrMore = false;
      var maxCoinLanes = 0;
      for (var i = 0; i < 2000; i++) {
        final segment = gen.next(i * 1.5);
        if (segment.coinLanes.length >= 2) sawTwoOrMore = true;
        maxCoinLanes = segment.coinLanes.length > maxCoinLanes
            ? segment.coinLanes.length
            : maxCoinLanes;
        // Nunca puede haber más monedas en la fila que carriles.
        expect(segment.coinLanes.toSet().length, segment.coinLanes.length);
        expect(segment.coinLanes.length, lessThanOrEqualTo(3));
      }
      expect(
        sawTwoOrMore,
        isTrue,
        reason: 'expected at least one clustered row with 2+ coins',
      );
      expect(maxCoinLanes, greaterThanOrEqualTo(2));
    });

    test('coin clusters keep happening at high difficulty, not only early', () {
      // A score alto (~d cercano a 1) el generador normal bloquea 2
      // carriles casi siempre; sin el fix de _coinTrailMask esto se
      // quedaría siempre en 1 moneda por fila pasado el arranque.
      for (final seed in [1, 2, 3, 4, 5]) {
        final gen = SegmentGenerator(runSeed: seed);
        var sawTwoOrMore = false;
        for (var i = 0; i < 400; i++) {
          final segment = gen.next(900); // score fijo, dificultad ~máxima
          if (segment.coinLanes.length >= 2) sawTwoOrMore = true;
        }
        expect(
          sawTwoOrMore,
          isTrue,
          reason: 'seed=$seed: no clustering seen at high difficulty',
        );
      }
    });
  });
}
