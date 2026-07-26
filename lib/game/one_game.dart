import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants/game_constants.dart';
import '../domain/catalogs/skin_catalog.dart';
import '../domain/entities/skin.dart';
import '../generation/difficulty.dart';
import '../generation/segment_generator.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';

enum OneGameState { playing, dying, dead }

class OneGame extends FlameGame with TapCallbacks {
  OneGame({
    required this.skinId,
    required this.bgColor,
    required this.laneColor,
    required this.obstacleColor,
    required this.accentColor,
    required this.reduceMotion,
    required this.onScore,
    required this.onOrb,
    required this.onDeath,
    required this.onTapLane,
    int? seed,
  }) : runSeed = seed ?? Random().nextInt(1 << 31);

  final String skinId;
  final Color bgColor;
  final Color laneColor;
  final Color obstacleColor;
  final Color accentColor;
  final bool reduceMotion;
  final void Function(int score) onScore;
  final VoidCallback onOrb;
  final void Function(int score, double duration, int orbs, int deathLane)
      onDeath;
  final VoidCallback onTapLane;

  final int runSeed;
  final DifficultyCurve curve = const DifficultyCurve();

  late SegmentGenerator generator;
  late PlayerComponent player;
  SkinDef get skin => SkinCatalog.byId(skinId);

  OneGameState state = OneGameState.playing;
  double score = 0;
  double elapsed = 0;
  int orbs = 0;
  int orbCombo = 0;
  bool collectedAnyOrb = false;

  double _spawnTimer = 0;
  double _dieTimer = 0;
  double _pulse = 0;
  double _scrollOffset = 0;

  final List<ObstacleRowComponent> _obstacles = [];
  final List<OrbComponent> _orbs = [];
  final List<Sprite> _treeSprites = [];

  static const List<String> _treeAssetNames = [
    'nature/trees/pine_0.png',
    'nature/trees/pine_1.png',
    'nature/trees/pine_2.png',
    'nature/trees/pine_3.png',
    'nature/trees/pine_4.png',
    'nature/trees/pine_5.png',
    'nature/trees/pine_6.png',
    'nature/trees/pine_7.png',
  ];

  double get _laneWidth => size.x / GameConstants.laneCount;
  double get _originX => 0;
  double get _rowHeight => 64;

  @override
  Color backgroundColor() => bgColor;

  @override
  Future<void> onLoad() async {
    for (final name in _treeAssetNames) {
      try {
        final image = await Flame.images.load(name);
        _treeSprites.add(Sprite(image));
      } catch (_) {}
    }

    generator = SegmentGenerator(runSeed: runSeed);
    player = PlayerComponent(skin: skin);
    await add(player);
    player.layout(
      laneWidth: _laneWidth,
      originX: _originX,
      y: size.y * GameConstants.playerYFactor,
    );
    for (var i = 0; i < 5; i++) {
      _spawnSegment(initialY: -80.0 - i * 140);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    player.layout(
      laneWidth: _laneWidth,
      originX: _originX,
      y: size.y * GameConstants.playerYFactor,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state != OneGameState.playing) return;
    player.cycleLane();
    onTapLane();
  }

  void _spawnSegment({double? initialY}) {
    final segment = generator.next(score);
    final y = initialY ?? -_rowHeight;
    if (segment.hasObstacle) {
      final row = ObstacleRowComponent(
        mask: segment.obstacleMask,
        laneWidth: _laneWidth,
        originX: _originX,
        rowHeight: _rowHeight,
        color: obstacleColor,
        treeSprites: _treeSprites,
      )..position = Vector2(0, y);
      _obstacles.add(row);
      add(row);
    }
    if (segment.hasOrb) {
      final orb = OrbComponent(
        lane: segment.orbLane,
        laneWidth: _laneWidth,
        originX: _originX,
        color: accentColor,
      )..layoutY(y);
      _orbs.add(orb);
      add(orb);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;

    if (state == OneGameState.dying) {
      _dieTimer += dt;
      if (_dieTimer >= 0.12) {
        state = OneGameState.dead;
        onDeath(score.floor(), elapsed, orbs, player.lane);
      }
      return;
    }
    if (state != OneGameState.playing) return;

    elapsed += dt;
    score += GameConstants.scorePerSecond * dt;
    onScore(score.floor());

    final d = curve.difficultyForScore(score);
    final speed = curve.scrollSpeed(d);
    final gap = curve.gapSeconds(d);

    _scrollOffset = (_scrollOffset + speed * dt) % 64;

    for (final o in _obstacles) {
      o.position.y += speed * dt;
    }
    for (final orb in _orbs) {
      orb.position.y += speed * dt;
    }

    _spawnTimer += dt;
    if (_spawnTimer >= gap) {
      _spawnTimer = 0;
      _spawnSegment();
    }

    for (final orb in _orbs) {
      if (orb.tryCollect(
        playerLane: player.lane,
        playerX: player.position.x,
        playerY: player.position.y,
        playerRadius: GameConstants.playerRadius,
      )) {
        orbs += 1;
        collectedAnyOrb = true;
        orbCombo += 1;
        score += GameConstants.orbScore.toDouble();
        if (orbCombo % GameConstants.comboEvery == 0) {
          score += 1;
        }
        onOrb();
        orb.removeFromParent();
      }
    }
    _orbs.removeWhere((o) => o.collected || o.position.y > size.y + 80);

    for (final row in _obstacles) {
      if (row.hitsPlayer(
        playerLane: player.lane,
        playerY: player.position.y,
        playerRadius: GameConstants.playerRadius,
      )) {
        _startDeath();
        break;
      }
    }

    for (final row in List<ObstacleRowComponent>.from(_obstacles)) {
      if (row.position.y > size.y + 100) {
        row.removeFromParent();
        _obstacles.remove(row);
      }
    }
  }

  void _startDeath() {
    if (state != OneGameState.playing) return;
    state = OneGameState.dying;
    _dieTimer = 0;
  }

  void _drawNightGrass(Canvas canvas, Size screen) {
    final rect = Offset.zero & screen;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF071018),
            Color(0xFF0B1A14),
            Color(0xFF102418),
            Color(0xFF0E1F15),
          ],
          stops: [0.0, 0.28, 0.7, 1.0],
        ).createShader(rect),
    );

    // Soft drifting moss patches (no grid).
    final patch = Paint()..color = const Color(0x0C1F4A34);
    for (var i = 0; i < 18; i++) {
      final x = ((i * 73) % 97) / 97.0 * screen.width;
      final y =
          (((i * 41) % 83) / 83.0 * screen.height + _scrollOffset * 0.35) %
              (screen.height + 40) -
          20;
      final rw = 40.0 + (i % 5) * 12;
      final rh = 18.0 + (i % 3) * 8;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: rw, height: rh),
        patch,
      );
    }

    // Sparse irregular grass tips (not aligned to a grid).
    final blade = Paint()
      ..color = const Color(0x2816A34A)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 55; i++) {
      final x = ((i * 97 + 13) % 200) / 200.0 * screen.width;
      final base =
          (((i * 53 + 7) % 160) / 160.0 * screen.height - _scrollOffset) %
              (screen.height + 30);
      final h = 4.0 + (i % 4);
      final lean = ((i % 5) - 2).toDouble();
      canvas.drawLine(Offset(x, base), Offset(x + lean, base - h), blade);
    }

    // Subtle lane hints in deep green (no gray lines).
    final lanePaint = Paint()
      ..color = const Color(0x221A3326)
      ..strokeWidth = 2;
    for (var i = 1; i < GameConstants.laneCount; i++) {
      final x = _laneWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, screen.height), lanePaint);
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.15,
          colors: [
            Color(0x00000000),
            Color(0x55000000),
          ],
        ).createShader(rect),
    );
  }

  @override
  void render(Canvas canvas) {
    final screen = Size(size.x, size.y);
    _drawNightGrass(canvas, screen);

    super.render(canvas);

    if (state == OneGameState.dying && !reduceMotion) {
      canvas.drawRect(
        Offset.zero & screen,
        Paint()..color = const Color(0x33FB7185),
      );
    }

    if (!reduceMotion && isLoaded) {
      final a = (sin(_pulse * 2) + 1) * 0.5;
      canvas.drawCircle(
        Offset(player.position.x, player.position.y),
        GameConstants.playerRadius + 8 + a * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accentColor.withValues(alpha: 0.18 + a * 0.12),
      );
    }
  }
}
