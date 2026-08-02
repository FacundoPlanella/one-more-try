import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants/game_constants.dart';
import '../domain/catalogs/skin_catalog.dart';
import '../domain/entities/perk.dart';
import '../domain/entities/skin.dart';
import '../generation/difficulty.dart';
import '../generation/segment.dart';
import '../generation/segment_generator.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';

enum OneGameState { playing, dying, dead }

class OneGame extends FlameGame with TapCallbacks {
  OneGame({
    required this.skinId,
    required this.accentColor,
    required this.reduceMotion,
    required this.onScore,
    required this.onOrb,
    required this.onCoin,
    required this.onDeath,
    required this.onTapLane,
    this.activePerks = const {},
    int? seed,
  }) : runSeed = seed ?? Random().nextInt(1 << 31);

  final String skinId;
  final Color accentColor;
  final bool reduceMotion;
  final Set<PerkEffect> activePerks;
  final void Function(int score) onScore;
  final VoidCallback onOrb;
  final VoidCallback onCoin;
  final void Function(
    int score,
    double duration,
    int orbs,
    int coins,
    int deathLane,
  ) onDeath;
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
  int coins = 0;
  int orbCombo = 0;
  bool collectedAnyOrb = false;

  bool _shieldActive = false;
  double _magnetTimer = 0;
  double _slowmoTimer = 0;
  double _multiplierTimer = 0;
  double _shieldFlashTimer = 0;

  bool get shieldActive => _shieldActive;
  double get magnetTimer => _magnetTimer;
  double get slowmoTimer => _slowmoTimer;
  double get multiplierTimer => _multiplierTimer;

  double _spawnTimer = 0;
  double _dieTimer = 0;
  double _pulse = 0;
  double _scrollOffset = 0;

  /// true si la última fila generada tenía monedas de racha: hace que la
  /// próxima fila se dispare mucho más cerca (ver [_coinTrailRowSpacing]) en
  /// vez de esperar el gap normal entre obstáculos, así el patrón se ve
  /// como una línea/cluster conectado en pantalla y no filas sueltas a
  /// cientos de píxeles de distancia.
  bool _lastSpawnWasCoinTrail = false;
  static const double _coinTrailRowSpacing = 110; // px entre filas de racha

  /// Fondo: el matiz rota con el score mientras saturación y luminosidad se
  /// mantienen fijas, así el contraste contra obstáculos/carriles no cambia
  /// de un tramo a otro (antes sí, porque los stops tenían brillos distintos).
  static const double _bgStopScore = 100; // "cambia cada 100 puntos"
  static const double _bgDegreesPerStop = 30; // vuelta completa cada 1200 pts
  static const double _bgBaseHue = 210; // arranca en el azul-gris de marca
  static const double _bgSaturation = 0.34;
  static const double _bgLightness = 0.095;

  final List<ObstacleRowComponent> _obstacles = [];
  final List<OrbComponent> _orbs = [];

  double get _laneWidth => size.x / GameConstants.laneCount;
  double get _originX => 0;
  double get _rowHeight => 56;

  Color get _currentBg => _bgForScore(score);
  Color get _currentLane =>
      Color.lerp(_currentBg, Colors.white, 0.08)!.withValues(alpha: 0.35);
  Color get _currentObstacle =>
      Color.lerp(_currentBg, Colors.white, 0.22)!;

  static Color _bgForScore(double score) {
    final hue = (_bgBaseHue + (score / _bgStopScore) * _bgDegreesPerStop) % 360;
    return HSLColor.fromAHSL(1.0, hue, _bgSaturation, _bgLightness).toColor();
  }

  @override
  Color backgroundColor() => _currentBg;

  @override
  Future<void> onLoad() async {
    generator = SegmentGenerator(runSeed: runSeed);
    player = PlayerComponent(skin: skin);
    if (activePerks.contains(PerkEffect.startWithShield)) {
      _shieldActive = true;
    }
    await add(player);
    player.layout(
      laneWidth: _laneWidth,
      originX: _originX,
      y: size.y * GameConstants.playerYFactor,
    );
    // Mismo criterio de espaciado que usa update() más adelante: si no, una
    // racha de monedas que arranca dentro de este burst inicial (muy común,
    // el primer intervalo posible es a los 2 segmentos) queda con el
    // espaciado fijo de abajo sin importar si es una fila de racha, y dos
    // monedas del mismo patrón terminan pegadas.
    final d0 = curve.difficultyForScore(score);
    final normalSpacing = curve.scrollSpeed(d0) * curve.gapSeconds(d0);
    var y = -_rowHeight;
    for (var i = 0; i < 5; i++) {
      _lastSpawnWasCoinTrail = _spawnSegment(initialY: y);
      y -= _lastSpawnWasCoinTrail ? _coinTrailRowSpacing : normalSpacing;
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

  /// Devuelve true si la fila generada tiene monedas de racha: el llamador
  /// usa esto para espaciar la próxima fila mucho más cerca (ver
  /// [_lastSpawnWasCoinTrail]), si no las filas de un mismo patrón quedan a
  /// cientos de píxeles entre sí y nunca se ven como una línea conectada.
  bool _spawnSegment({double? initialY}) {
    final segment = generator.next(score);
    final y = initialY ?? -_rowHeight;
    if (segment.hasObstacle) {
      final row = ObstacleRowComponent(
        mask: segment.obstacleMask,
        laneWidth: _laneWidth,
        originX: _originX,
        rowHeight: _rowHeight,
        color: _currentObstacle,
      )..position = Vector2(0, y);
      _obstacles.add(row);
      add(row);
    }
    if (segment.hasPickup) {
      final type = segment.pickupType!;
      final orb = OrbComponent(
        type: type,
        lane: segment.pickupLane,
        laneWidth: _laneWidth,
        originX: _originX,
        color: _colorForPickup(type),
      )..layoutY(y);
      _orbs.add(orb);
      add(orb);
    }
    for (final lane in segment.coinLanes) {
      final orb = OrbComponent(
        type: PickupType.coin,
        lane: lane,
        laneWidth: _laneWidth,
        originX: _originX,
        color: _colorForPickup(PickupType.coin),
      )..layoutY(y);
      _orbs.add(orb);
      add(orb);
    }
    return segment.hasCoinLanes;
  }

  Color _colorForPickup(PickupType type) {
    switch (type) {
      case PickupType.score:
        return accentColor;
      case PickupType.coin:
        return const Color(0xFFFACC15);
      case PickupType.magnet:
        return const Color(0xFF60A5FA);
      case PickupType.shield:
        return const Color(0xFF34D399);
      case PickupType.slowmo:
        return const Color(0xFF818CF8);
      case PickupType.multiplier:
        return const Color(0xFFF472B6);
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
        onDeath(score.floor(), elapsed, orbs, coins, player.lane);
      }
      return;
    }
    if (state != OneGameState.playing) return;

    elapsed += dt;
    final multiplierActive = _multiplierTimer > 0;
    score += GameConstants.scorePerSecond * dt * (multiplierActive ? 2 : 1);
    onScore(score.floor());

    if (_magnetTimer > 0) _magnetTimer = max(0, _magnetTimer - dt);
    if (_slowmoTimer > 0) _slowmoTimer = max(0, _slowmoTimer - dt);
    if (_multiplierTimer > 0) _multiplierTimer = max(0, _multiplierTimer - dt);
    if (_shieldFlashTimer > 0) {
      _shieldFlashTimer = max(0, _shieldFlashTimer - dt);
    }

    // Actualiza color de obstáculos vivos para que acompañen el fondo.
    final obstacleTint = _currentObstacle;
    for (final o in _obstacles) {
      o.color = obstacleTint;
    }

    final d = curve.difficultyForScore(score);
    final speed =
        curve.scrollSpeed(d) * (_slowmoTimer > 0 ? GameConstants.slowmoFactor : 1.0);
    final gap = curve.gapSeconds(d);

    // Parallax lento: el fondo se mueve mucho más despacio que los obstáculos.
    _scrollOffset = (_scrollOffset + speed * dt * 0.12) % 120;

    for (final o in _obstacles) {
      o.position.y += speed * dt;
    }

    final magnetActive = _magnetTimer > 0;
    final magnetReach = activePerks.contains(PerkEffect.biggerMagnet) ? 160.0 : 90.0;
    for (final orb in _orbs) {
      if (orb.collected) continue;
      if (!orb.attracting && magnetActive) {
        final dy = (orb.position.y - player.position.y).abs();
        if (dy <= magnetReach) {
          orb.attracting = true;
        }
      }
      if (orb.attracting) {
        final toPlayer = player.position - orb.position;
        final dist = toPlayer.length;
        if (dist > 1) {
          orb.position += toPlayer.normalized() *
              min(GameConstants.magnetPullSpeed * dt, dist);
        }
      } else {
        orb.position.y += speed * dt;
      }
    }

    _spawnTimer += dt;
    // Filas de racha se disparan mucho más seguido (distancia fija en vez
    // del gap normal) para que se vean pegadas unas a otras en pantalla.
    final spawnGap =
        _lastSpawnWasCoinTrail ? _coinTrailRowSpacing / speed : gap;
    if (_spawnTimer >= spawnGap) {
      _spawnTimer = 0;
      _lastSpawnWasCoinTrail = _spawnSegment();
    }

    for (final orb in _orbs) {
      if (orb.tryCollect(
        playerLane: player.lane,
        playerX: player.position.x,
        playerY: player.position.y,
        playerRadius: GameConstants.playerRadius,
        ignoreLane: orb.attracting,
      )) {
        switch (orb.type) {
          case PickupType.score:
            orbs += 1;
            collectedAnyOrb = true;
            orbCombo += 1;
            score += GameConstants.orbScore * (multiplierActive ? 2 : 1);
            if (orbCombo % GameConstants.comboEvery == 0) {
              score += 1;
            }
            onOrb();
          case PickupType.coin:
            final base = GameConstants.coinValue +
                (activePerks.contains(PerkEffect.richerCoins)
                    ? GameConstants.richerCoinsBonus
                    : 0);
            coins += base * (multiplierActive ? 2 : 1);
            onCoin();
          case PickupType.magnet:
            _magnetTimer = GameConstants.magnetSeconds;
          case PickupType.shield:
            _shieldActive = true;
          case PickupType.slowmo:
            _slowmoTimer = GameConstants.slowmoSeconds;
          case PickupType.multiplier:
            _multiplierTimer = GameConstants.multiplierSeconds;
        }
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
        if (_shieldActive) {
          _shieldActive = false;
          _shieldFlashTimer = GameConstants.shieldInvulnSeconds;
        } else if (_shieldFlashTimer <= 0) {
          // Sin esto, el mismo obstáculo que gastó el escudo mata al jugador
          // un frame después (sigue "tocando" al jugador mientras cruza).
          _startDeath();
        }
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

  void _drawGenericBg(Canvas canvas, Size screen) {
    final rect = Offset.zero & screen;
    final bg = _currentBg;
    final top = Color.lerp(bg, Colors.white, 0.04)!;
    final bottom = Color.lerp(bg, Colors.black, 0.18)!;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bg, bottom],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Soft drifting blobs — generic atmosphere, no themed art.
    final blob = Paint()
      ..color = Color.lerp(bg, accentColor, 0.35)!.withValues(alpha: 0.05);
    for (var i = 0; i < 10; i++) {
      final x = ((i * 73) % 97) / 97.0 * screen.width;
      final y =
          (((i * 41) % 83) / 83.0 * screen.height + _scrollOffset * 0.25) %
              (screen.height + 60) -
          30;
      final r = 28.0 + (i % 4) * 14;
      canvas.drawCircle(Offset(x, y), r, blob);
    }

    // Subtle lane guides.
    final lanePaint = Paint()
      ..color = _currentLane
      ..strokeWidth = 1.4;
    for (var i = 1; i < GameConstants.laneCount; i++) {
      final x = _laneWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, screen.height), lanePaint);
    }

    // Soft vignette.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 1.2,
          colors: [
            const Color(0x00000000),
            Colors.black.withValues(alpha: 0.28),
          ],
        ).createShader(rect),
    );
  }

  @override
  void render(Canvas canvas) {
    final screen = Size(size.x, size.y);
    _drawGenericBg(canvas, screen);

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

    if (isLoaded && (_shieldActive || _shieldFlashTimer > 0)) {
      final flash = _shieldFlashTimer > 0;
      canvas.drawCircle(
        Offset(player.position.x, player.position.y),
        GameConstants.playerRadius + (flash ? 10 : 5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = flash ? 3 : 2
          ..color = const Color(0xFF34D399)
              .withValues(alpha: flash ? 0.9 : 0.7),
      );
    }

    if (isLoaded && _magnetTimer > 0) {
      _drawPowerRing(canvas, const Color(0xFF60A5FA), 6);
    }
    if (isLoaded && _slowmoTimer > 0) {
      _drawPowerRing(canvas, const Color(0xFF818CF8), 9);
    }
    if (isLoaded && _multiplierTimer > 0) {
      _drawPowerRing(canvas, const Color(0xFFF472B6), 12);
    }
  }

  /// Anillo pulsante alrededor del jugador para dejar bien claro que un
  /// poder está activo (antes solo se veía en un badge chico del HUD).
  void _drawPowerRing(Canvas canvas, Color color, double extraRadius) {
    final a = (sin(_pulse * 5) + 1) * 0.5;
    canvas.drawCircle(
      Offset(player.position.x, player.position.y),
      GameConstants.playerRadius + extraRadius + a * 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color.withValues(alpha: 0.55 + a * 0.3),
    );
  }
}
