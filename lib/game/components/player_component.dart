import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/skin.dart';

class PlayerComponent extends PositionComponent {
  PlayerComponent({required this.skin});

  SkinDef skin;
  int lane = 1;
  double _displayLane = 1;
  final List<Offset> _trail = [];
  Sprite? _sprite;

  double laneWidth = 0;
  double originX = 0;

  /// Escala aplicada a radio/sprite/trail para que el jugador guarde
  /// siempre la misma proporción contra el ancho de carril real (ver
  /// `OneGame._sizeScale`) en vez de un tamaño fijo en píxeles.
  double sizeScale = 1.0;

  static const double _baseSpriteSize = 40;

  void cycleLane() {
    lane = (lane + 1) % GameConstants.laneCount;
  }

  void layout({
    required double laneWidth,
    required double originX,
    required double y,
    double? sizeScale,
  }) {
    this.laneWidth = laneWidth;
    this.originX = originX;
    if (sizeScale != null) this.sizeScale = sizeScale;
    position.y = y;
    _snapX();
  }

  void _snapX() {
    position.x = originX + (_displayLane + 0.5) * laneWidth;
  }

  @override
  Future<void> onLoad() async {
    await _loadSprite();
  }

  Future<void> _loadSprite() async {
    final path = skin.spriteAsset;
    if (path == null) {
      _sprite = null;
      return;
    }
    try {
      final relative = path
          .replaceFirst('assets/images/', '')
          .replaceFirst('assets/', '');
      final image = await Flame.images.load(relative);
      _sprite = Sprite(image);
    } catch (_) {
      _sprite = null;
    }
  }

  Future<void> applySkin(SkinDef next) async {
    skin = next;
    await _loadSprite();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final speed = 1 / GameConstants.laneSwitchDuration;
    if ((_displayLane - lane).abs() < 0.001) {
      _displayLane = lane.toDouble();
    } else {
      final dir = lane > _displayLane ? 1.0 : -1.0;
      _displayLane += dir * speed * dt;
      if ((dir > 0 && _displayLane > lane) || (dir < 0 && _displayLane < lane)) {
        _displayLane = lane.toDouble();
      }
    }
    _snapX();

    _trail.insert(0, Offset(position.x, position.y));
    final maxTrail = skin.dualTrail ? 14 : 10;
    if (_trail.length > maxTrail) {
      _trail.removeRange(maxTrail, _trail.length);
    }
  }

  @override
  void render(Canvas canvas) {
    final r = GameConstants.playerRadius * sizeScale;
    final spriteSize = _baseSpriteSize * sizeScale;

    for (var i = _trail.length - 1; i >= 0; i--) {
      final t = 1 - i / _trail.length;
      final p = _trail[i];
      final paint = Paint()
        ..color = skin.color.withValues(alpha: 0.12 * t);
      canvas.drawCircle(Offset(p.dx - position.x, p.dy - position.y), r * 0.7 * t, paint);
      if (skin.dualTrail && skin.secondary != null && i.isOdd) {
        final paint2 = Paint()
          ..color = skin.secondary!.withValues(alpha: 0.1 * t);
        canvas.drawCircle(
          Offset(p.dx - position.x + 6, p.dy - position.y),
          r * 0.5 * t,
          paint2,
        );
      }
    }

    final sprite = _sprite;
    if (sprite != null) {
      canvas.save();
      if (skin.ghost) {
        canvas.saveLayer(
          Rect.fromCenter(
            center: Offset.zero,
            width: spriteSize,
            height: spriteSize,
          ),
          Paint()..color = const Color(0x8CFFFFFF),
        );
      }
      sprite.render(
        canvas,
        size: Vector2.all(spriteSize),
        anchor: Anchor.center,
        overridePaint: Paint()..filterQuality = FilterQuality.none,
      );
      if (skin.ghost) {
        canvas.restore();
      }
      canvas.restore();
      return;
    }

    final fill = Paint()
      ..color = skin.ghost ? skin.color.withValues(alpha: 0.55) : skin.color;
    if (skin.prism && skin.secondary != null) {
      fill.shader = Gradient.linear(
        Offset(-r, -r),
        Offset(r, r),
        [skin.color, skin.secondary!],
      );
    }
    canvas.drawCircle(Offset.zero, r, fill);

    if (skin.secondary != null && skin.id == 'midnight') {
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = skin.secondary!,
      );
    }
  }
}
