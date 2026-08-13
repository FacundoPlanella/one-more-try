import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../core/constants/game_constants.dart';
import '../../generation/segment.dart';

/// Obstáculos genéricos: bloques redondeados (sin sprites).
class ObstacleRowComponent extends PositionComponent {
  ObstacleRowComponent({
    required this.mask,
    required this.laneWidth,
    required this.originX,
    required this.rowHeight,
    required this.color,
  }) : super(priority: 0);

  final int mask;
  double laneWidth;
  double originX;
  final double rowHeight;
  Color color;

  bool get isOffscreen => position.y - rowHeight > 2000;

  @override
  void render(Canvas canvas) {
    final fill = Paint()..color = color;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Color.lerp(color, const Color(0xFFFFFFFF), 0.12)!
          .withValues(alpha: 0.35);

    final h = rowHeight * 0.52;
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      if (!LaneMask.isBlocked(mask, lane)) continue;
      final x = originX + lane * laneWidth + laneWidth * 0.14 - position.x;
      final w = laneWidth * 0.72;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, -h / 2, w, h),
        const Radius.circular(12),
      );
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, edge);
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
    final half = rowHeight * 0.52 / 2;
    return dy < half + playerRadius * (1 - GameConstants.hitboxForgiveness);
  }
}

class OrbComponent extends PositionComponent {
  OrbComponent({
    required this.type,
    required this.lane,
    required this.laneWidth,
    required this.originX,
    required this.color,
  }) : super(priority: 1);

  final PickupType type;
  final int lane;
  double laneWidth;
  double originX;
  final Color color;
  bool collected = false;

  /// true mientras el imán la está atrayendo hacia el jugador (animación de
  /// atracción real, no solo un radio de recolección más grande).
  bool attracting = false;

  /// Punto de llegada propio, levemente distinto al centro exacto del
  /// jugador: si varias monedas atraen a la vez y todas apuntan al mismo
  /// píxel, se ven "apiladas" una arriba de otra en vez de llegar cada una
  /// por su lado. Se asigna una sola vez, al empezar a atraer.
  Vector2 attractOffset = Vector2.zero();

  Sprite? _icon;

  void layoutY(double y) {
    position = Vector2(originX + (lane + 0.5) * laneWidth, y);
  }

  /// Recalcula solo la X (según el nuevo ancho de carril), preservando la Y
  /// —que representa el progreso de scroll, no la posición horizontal—.
  void updateLaneWidth(double newLaneWidth, double newOriginX) {
    laneWidth = newLaneWidth;
    originX = newOriginX;
    position.x = originX + (lane + 0.5) * laneWidth;
  }

  @override
  Future<void> onLoad() async {
    final path = _iconAssetFor(type);
    if (path == null) return;
    try {
      final image = await Flame.images.load(path);
      _icon = Sprite(image);
    } catch (_) {
      _icon = null;
    }
  }

  /// Ícono real (assets/images/ui/) para los tipos con arte propio; el resto
  /// sigue usando el glyph vectorial de [_renderGlyph].
  static String? _iconAssetFor(PickupType type) {
    switch (type) {
      case PickupType.coin:
        return 'ui/coin.png';
      case PickupType.shield:
        return 'ui/shield.png';
      case PickupType.score:
      case PickupType.magnet:
      case PickupType.slowmo:
      case PickupType.multiplier:
        return null;
    }
  }

  /// [ignoreLane] se usa mientras el imán ya la está arrastrando hacia el
  /// jugador (ver [attracting]): en ese caso alcanza con la cercanía real,
  /// sin importar en qué carril arrancó.
  bool tryCollect({
    required int playerLane,
    required double playerX,
    required double playerY,
    required double playerRadius,
    bool ignoreLane = false,
  }) {
    if (collected) return false;
    if (!ignoreLane && playerLane != lane) return false;
    final reach = playerRadius + 10;
    final dx = position.x - playerX;
    final dy = position.y - playerY;
    if (dx * dx + dy * dy <= reach * reach) {
      collected = true;
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    if (collected) return;

    final icon = _icon;
    if (icon != null) {
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()..color = color.withValues(alpha: 0.22),
      );
      icon.render(
        canvas,
        position: Vector2.zero(),
        size: Vector2.all(18),
        anchor: Anchor.center,
        overridePaint: Paint()..filterQuality = FilterQuality.none,
      );
      return;
    }

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
    _renderGlyph(canvas);
  }

  /// Ícono simple por tipo, sin depender de sprites externos.
  void _renderGlyph(Canvas canvas) {
    final glyphPaint = Paint()..color = const Color(0xE6101012);
    switch (type) {
      case PickupType.score:
        return;
      case PickupType.coin:
        canvas.drawCircle(Offset.zero, 3.2, glyphPaint);
      case PickupType.magnet:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 3, height: 7),
          glyphPaint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: const Offset(-2.5, 3), width: 8, height: 3),
          glyphPaint,
        );
      case PickupType.shield:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 8, height: 9),
            const Radius.circular(3),
          ),
          glyphPaint,
        );
      case PickupType.slowmo:
        canvas.drawLine(Offset.zero, const Offset(0, -4), glyphPaint..strokeWidth = 1.6);
        canvas.drawLine(Offset.zero, const Offset(3, 1), glyphPaint..strokeWidth = 1.6);
      case PickupType.multiplier:
        canvas.drawLine(const Offset(-3, -3), const Offset(3, 3), glyphPaint..strokeWidth = 1.8);
        canvas.drawLine(const Offset(-3, 3), const Offset(3, -3), glyphPaint..strokeWidth = 1.8);
    }
  }
}
