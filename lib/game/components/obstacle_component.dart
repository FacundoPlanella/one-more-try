import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../core/constants/game_constants.dart';
import '../../generation/segment.dart';
import '../lane_perspective.dart';

/// Obstáculos: roca giratoria (assets/images/obstacles/roca_giro_01..10.png,
/// animación de 10 frames) recortada a lo Cover para llenar cada celda de
/// carril, sin bordes.
class ObstacleRowComponent extends PositionComponent {
  ObstacleRowComponent({
    required this.mask,
    required this.laneWidth,
    required this.originX,
    required this.rowHeight,
    required this.collisionHeight,
    required this.color,
    required this.centerX,
    required this.horizonSpread,
    required this.playerY,
  }) : super(priority: 0);

  static const int _frameCount = 10;

  /// Segundos por frame: 10 frames a este ritmo dan una vuelta completa
  /// cada 0.7s, un giro rápido pero legible.
  static const double _frameDuration = 0.07;

  final int mask;
  double laneWidth;
  double originX;
  double rowHeight;
  double collisionHeight;
  Color color;

  /// Punto de fuga horizontal del fondo y cuánto se angosta el camino en el
  /// borde superior visible (ver `ForestBackgroundLanes`).
  double centerX;
  double horizonSpread;
  double playerY;

  List<Image> _frames = const [];
  double _animTime = 0;

  bool get isOffscreen => position.y - rowHeight > 2000;

  @override
  Future<void> onLoad() async {
    try {
      _frames = await Future.wait([
        for (var i = 1; i <= _frameCount; i++)
          Flame.images.load('obstacles/roca_giro_${i.toString().padLeft(2, '0')}.png'),
      ]);
    } catch (_) {
      _frames = const [];
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    final fill = Paint()..color = color;
    final frames = _frames;
    final image = frames.isEmpty
        ? null
        : frames[(_animTime / _frameDuration).floor() % frames.length];
    final h = rowHeight * GameConstants.obstacleHitHeightFactor;
    final rowY = position.y;
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      if (!LaneMask.isBlocked(mask, lane)) continue;
      final cellLeftFlat = originX + lane * laneWidth + laneWidth * 0.14;
      final cellRightFlat = cellLeftFlat + laneWidth * 0.72;
      final left = LanePerspective.apply(
            flatX: cellLeftFlat,
            y: rowY,
            playerY: playerY,
            centerX: centerX,
            horizonSpread: horizonSpread,
          ) -
          position.x;
      final right = LanePerspective.apply(
            flatX: cellRightFlat,
            y: rowY,
            playerY: playerY,
            centerX: centerX,
            horizonSpread: horizonSpread,
          ) -
          position.x;
      final rect = Rect.fromLTWH(left, -h / 2, right - left, h);
      if (image != null) {
        _drawCover(canvas, image, rect);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          fill,
        );
      }
    }
  }

  /// Recorta [image] para llenar [dst] por completo (equivalente a
  /// BoxFit.cover) en vez de deformarla o dejarla más chica que la celda.
  void _drawCover(Canvas canvas, Image image, Rect dst) {
    final srcW = image.width.toDouble();
    final srcH = image.height.toDouble();
    final srcAspect = srcW / srcH;
    final dstAspect = dst.width / dst.height;
    final Rect src;
    if (srcAspect > dstAspect) {
      final cropW = srcH * dstAspect;
      src = Rect.fromLTWH((srcW - cropW) / 2, 0, cropW, srcH);
    } else {
      final cropH = srcW / dstAspect;
      src = Rect.fromLTWH(0, (srcH - cropH) / 2, srcW, cropH);
    }
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  /// Colisión por carril con perdón horizontal.
  bool hitsPlayer({
    required int playerLane,
    required double playerY,
    required double playerRadius,
  }) {
    if (!LaneMask.isBlocked(mask, playerLane)) return false;
    final dy = (position.y - playerY).abs();
    final half =
        collisionHeight * GameConstants.obstacleHitHeightFactor / 2;
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
    this.sizeScale = 1.0,
  }) : super(priority: 1);

  final PickupType type;
  final int lane;
  double laneWidth;
  double originX;
  final Color color;
  bool collected = false;

  /// Mismo factor que `OneGame._sizeScale`, para que el tamaño dibujado
  /// guarde proporción con jugador/obstáculos en cualquier resolución.
  double sizeScale;

  /// true mientras el imán la está atrayendo hacia el jugador (animación de
  /// atracción real, no solo un radio de recolección más grande).
  bool attracting = false;

  /// Punto de llegada propio, levemente distinto al centro exacto del
  /// jugador: si varias monedas atraen a la vez y todas apuntan al mismo
  /// píxel, se ven "apiladas" una arriba de otra en vez de llegar cada una
  /// por su lado. Se asigna una sola vez, al empezar a atraer.
  Vector2 attractOffset = Vector2.zero();

  Sprite? _icon;

  /// X "plana" del centro del carril, antes de aplicar la perspectiva del
  /// camino (ver [applyPerspective]).
  double get flatX => originX + (lane + 0.5) * laneWidth;

  void layoutY(double y) {
    position.y = y;
    position.x = flatX;
  }

  /// Recalcula el ancho de carril tras un resize, preservando la Y —que
  /// representa el progreso de scroll, no la posición horizontal—. La X
  /// definitiva la fija [applyPerspective], que el caller debe invocar
  /// después (necesita playerY y la geometría del fondo, que este componente
  /// no conoce).
  void updateLaneWidth(double newLaneWidth, double newOriginX) {
    laneWidth = newLaneWidth;
    originX = newOriginX;
  }

  /// Ajusta la X visible para que la moneda siga el camino en perspectiva
  /// del fondo en vez de una grilla de carriles recta. Se llama cada frame
  /// mientras no está siendo atraída por el imán (ver [attracting]).
  void applyPerspective(double playerY, double centerX, double horizonSpread) {
    position.x = LanePerspective.apply(
      flatX: flatX,
      y: position.y,
      playerY: playerY,
      centerX: centerX,
      horizonSpread: horizonSpread,
    );
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

    // Escala uniforme (ver [sizeScale]) en vez de multiplicar cada radio a
    // mano: mantiene el ícono, el glow y el glyph proporcionados entre sí
    // sin duplicar la lógica de escalado en cada `drawCircle`.
    canvas.save();
    canvas.scale(sizeScale);

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
      canvas.restore();
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
    canvas.restore();
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
