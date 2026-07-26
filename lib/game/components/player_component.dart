import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/skin.dart';

class PlayerComponent extends PositionComponent {
  PlayerComponent({required this.skin});

  SkinDef skin;
  int lane = 1;
  double _displayLane = 1;
  final List<Offset> _trail = [];

  double laneWidth = 0;
  double originX = 0;

  void cycleLane() {
    lane = (lane + 1) % GameConstants.laneCount;
  }

  void layout({required double laneWidth, required double originX, required double y}) {
    this.laneWidth = laneWidth;
    this.originX = originX;
    position.y = y;
    _snapX();
  }

  void _snapX() {
    position.x = originX + (_displayLane + 0.5) * laneWidth;
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
    final r = GameConstants.playerRadius;

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
