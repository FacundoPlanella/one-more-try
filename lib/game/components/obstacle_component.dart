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
    this.sprites = const [],
  });

  final int mask;
  final double laneWidth;
  final double originX;
  final double rowHeight;
  final Color color;
  final List<Sprite> sprites;

  bool get isOffscreen => position.y - rowHeight > 2000;

  @override
  void render(Canvas canvas) {
    final h = rowHeight * 0.7;
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      if (!LaneMask.isBlocked(mask, lane)) continue;
      final x = originX + lane * laneWidth + laneWidth * 0.5 - position.x;
      final sprite = sprites.isEmpty
          ? null
          : sprites[lane % sprites.length];
      if (sprite != null) {
        final maxW = laneWidth * 0.72;
        final maxH = h;
        final src = sprite.srcSize;
        final scale = (maxW / src.x < maxH / src.y)
            ? maxW / src.x
            : maxH / src.y;
        final dw = src.x * scale;
        final dh = src.y * scale;
        sprite.render(
          canvas,
          position: Vector2(x - dw / 2, -dh / 2),
          size: Vector2(dw, dh),
          overridePaint: Paint()..filterQuality = FilterQuality.none,
        );
      } else {
        final paint = Paint()..color = color;
        final ox = originX + lane * laneWidth + laneWidth * 0.12 - position.x;
        final w = laneWidth * 0.76;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(ox, -h / 2, w, h),
          const Radius.circular(10),
        );
        canvas.drawRRect(rect, paint);
      }
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
