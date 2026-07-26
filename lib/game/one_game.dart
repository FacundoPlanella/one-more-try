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

  final List<ObstacleRowComponent> _obstacles = [];
  final List<OrbComponent> _orbs = [];
  final List<Sprite> _obstacleSprites = [];
  final Random _spriteRng = Random();

  static const List<String> _obstacleAssetNames = [
    'creatures/obstacles/obstacle_0.png',
    'creatures/obstacles/obstacle_1.png',
    'creatures/obstacles/obstacle_2.png',
    'creatures/obstacles/obstacle_3.png',
    'creatures/obstacles/obstacle_4.png',
    'creatures/obstacles/obstacle_5.png',
    'creatures/obstacles/obstacle_6.png',
    'creatures/obstacles/obstacle_7.png',
    'creatures/obstacles/obstacle_8.png',
    'creatures/obstacles/obstacle_9.png',
    'creatures/obstacles/obstacle_10.png',
    'creatures/obstacles/obstacle_11.png',
  ];

  double get _laneWidth => size.x / GameConstants.laneCount;
  double get _originX => 0;
  double get _rowHeight => 56;

  @override
  Color backgroundColor() => bgColor;

  @override
  Future<void> onLoad() async {
    for (final name in _obstacleAssetNames) {
      try {
        final image = await Flame.images.load(name);
        _obstacleSprites.add(Sprite(image));
      } catch (_) {
        // Keep geometric fallback if a sprite fails to load.
      }
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

  List<Sprite> _spritesForMask() {
    if (_obstacleSprites.isEmpty) return const [];
    final picked = <Sprite>[];
    for (var lane = 0; lane < GameConstants.laneCount; lane++) {
      picked.add(
        _obstacleSprites[_spriteRng.nextInt(_obstacleSprites.length)],
      );
    }
    return picked;
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
        sprites: _spritesForMask(),
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

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor,
            Color.lerp(bgColor, accentColor, 0.06)!,
          ],
        ).createShader(rect),
    );

    final lanePaint = Paint()
      ..color = laneColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2;
    for (var i = 1; i < GameConstants.laneCount; i++) {
      final x = _laneWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), lanePaint);
    }

    super.render(canvas);

    if (state == OneGameState.dying && !reduceMotion) {
      canvas.drawRect(
        rect,
        Paint()..color = const Color(0x33FB7185),
      );
    }

    if (!reduceMotion && isLoaded) {
      final a = (sin(_pulse * 2) + 1) * 0.5;
      canvas.drawCircle(
        Offset(player.position.x, player.position.y),
        GameConstants.playerRadius + 6 + a * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accentColor.withValues(alpha: 0.15 + a * 0.1),
      );
    }
  }
}
