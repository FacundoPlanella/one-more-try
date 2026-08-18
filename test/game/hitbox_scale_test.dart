import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/constants/game_constants.dart';
import 'package:one_more_try/game/forest_background_lanes.dart';

void main() {
  test('las filas de racha no solapan hitboxes en tablet', () {
    const canvases = <Size>[
      Size(360, 560),
      Size(360, 700),
      Size(800, 1150),
      Size(1024, 1230),
    ];

    for (final canvas in canvases) {
      final lanes = ForestBackgroundLanes.resolve(
        imageWidth: 1080,
        imageHeight: 1920,
        canvas: canvas,
        playerY: canvas.height * GameConstants.playerYFactor,
        laneCount: GameConstants.laneCount,
      );
      final scale = GameConstants.collisionScaleForLaneWidth(lanes.laneWidth);
      final window = GameConstants.rowHitHalfExtent(scale) * 2;

      expect(
        window,
        lessThan(GameConstants.coinTrailRowSpacing),
        reason:
            '${canvas.width}x${canvas.height}: ventana $window >= '
            '${GameConstants.coinTrailRowSpacing}',
      );
      expect(scale, lessThanOrEqualTo(GameConstants.maxSizeScale));
    }
  });

  test('en celular la escala de colisión no cambia', () {
    final lanes = ForestBackgroundLanes.resolve(
      imageWidth: 1080,
      imageHeight: 1920,
      canvas: const Size(360, 560),
      playerY: 560 * GameConstants.playerYFactor,
      laneCount: GameConstants.laneCount,
    );
    final scale = GameConstants.collisionScaleForLaneWidth(lanes.laneWidth);
    expect(scale, inInclusiveRange(0.75, 1.0));
  });
}
