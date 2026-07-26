import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/constants/game_constants.dart';
import '../../generation/segment.dart';

class ObstacleRowComponent extends PositionComponent {
  ObstacleRowComponent({
    required this.mask,
    required this.laneWidth,
    required this.originX,
    required this.rowHeight,
    required this.color,
  });

  final int mask;
  final double laneWidth;
  final double originX;
  final double rowHeight;
  final Color color;

  bool get isOffscreen => position.y - rowHeight > 2000;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    final h = rowHeight * 0.55;
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      if (!LaneMask.isBlocked(mask, lane)) continue;
      final x = originX + lane * laneWidth + laneWidth * 0.12;
      final w = laneWidth * 0.76;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - position.x, -h / 2, w, h),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  /// Colisión por carril con perdón horizontal.
  bool hitsPlayer({
    required int playerLane,
    required double playerY,
    required double playerRadius,
  }) {
    if (!LaneMask.isBlocked(mask, playerLane)) return false;
    final dy = (position.y - playerY).abs();
    final half = rowHeight * 0.55 / 2;
    return dy < half + playerRadius * (1 - GameConstants.hitboxForgiveness);
  }
}

class OrbComponent extends PositionComponent {
  OrbComponent({
    required this.lane,
    required this.laneWidth,
    required this.originX,
    required this.color,
  });

  final int lane;
  final double laneWidth;
  final double originX;
  final Color color;
  bool collected = false;

  void layoutY(double y) {
    position = Vector2(originX + (lane + 0.5) * laneWidth, y);
  }

  bool tryCollect({
    required int playerLane,
    required double playerX,
    required double playerY,
    required double playerRadius,
  }) {
    if (collected) return false;
    if (playerLane != lane) return false;
    final dx = position.x - playerX;
    final dy = position.y - playerY;
    if (dx * dx + dy * dy <= (playerRadius + 10) * (playerRadius + 10)) {
      collected = true;
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    if (collected) return;
    canvas.drawCircle(
      Offset.zero,
      7,
      Paint()..color = color.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset.zero,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.35),
    );
  }
}
