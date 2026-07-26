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
    this.treeSprites = const [],
  });

  final int mask;
  final double laneWidth;
  final double originX;
  final double rowHeight;
  final Color color;
  final List<Sprite> treeSprites;

  bool get isOffscreen => position.y - rowHeight > 2000;

  Sprite? _spriteForLane(int lane) {
    if (treeSprites.isEmpty) return null;
    final idx = (mask * 17 + lane * 13).abs() % treeSprites.length;
    return treeSprites[idx];
  }

  @override
  void render(Canvas canvas) {
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      if (!LaneMask.isBlocked(mask, lane)) continue;
      final cx = originX + lane * laneWidth + laneWidth * 0.5 - position.x;
      final sprite = _spriteForLane(lane);
      if (sprite != null) {
        _drawTreeSprite(canvas, cx, sprite);
      } else {
        _drawFallbackTree(canvas, cx, lane);
      }
    }
  }

  void _drawTreeSprite(Canvas canvas, double cx, Sprite sprite) {
    final maxW = laneWidth * 0.86;
    final maxH = rowHeight * 1.85;
    final src = sprite.srcSize;
    final scale = (maxW / src.x < maxH / src.y) ? maxW / src.x : maxH / src.y;
    final dw = src.x * scale;
    final dh = src.y * scale;
    // Anchor near the base so the trunk sits on the collision band.
    sprite.render(
      canvas,
      position: Vector2(cx - dw / 2, -dh * 0.72),
      size: Vector2(dw, dh),
      overridePaint: Paint()..filterQuality = FilterQuality.medium,
    );
  }

  void _drawFallbackTree(Canvas canvas, double cx, int lane) {
    final scale = 0.9 + ((mask + lane) % 3) * 0.08;
    final trunkW = laneWidth * 0.12 * scale;
    final trunkH = rowHeight * 0.42 * scale;
    final canopyR = laneWidth * 0.28 * scale;

    final trunk = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, trunkH * 0.15),
        width: trunkW,
        height: trunkH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(trunk, Paint()..color = const Color(0xFF3B2A1A));

    final canopyPaint = Paint()..color = const Color(0xFF163528);
    final canopyDark = Paint()..color = const Color(0xFF0E2418);
    final top = Offset(cx, -canopyR * 0.55);
    canvas.drawCircle(
      top.translate(-canopyR * 0.35, canopyR * 0.2),
      canopyR * 0.85,
      canopyDark,
    );
    canvas.drawCircle(
      top.translate(canopyR * 0.35, canopyR * 0.25),
      canopyR * 0.8,
      canopyDark,
    );
    canvas.drawCircle(top, canopyR, canopyPaint);
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
      10,
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset.zero,
      7,
      Paint()..color = color.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      Offset.zero,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.4),
    );
  }
}
