import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/flame.dart';
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
import 'forest_background_lanes.dart';
import 'lane_perspective.dart';

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
  /// Filas de obstáculo esquivadas con éxito (salieron de pantalla sin
  /// matar al jugador). Usado por el tutorial guiado del onboarding.
  int obstaclesCleared = 0;

  bool _shieldActive = false;
  double _magnetTimer = 0;
  double _slowmoTimer = 0;
  double _multiplierTimer = 0;
  double _shieldFlashTimer = 0;
  final Random _fxRng = Random();

  bool get shieldActive => _shieldActive;
  double get magnetTimer => _magnetTimer;
  double get slowmoTimer => _slowmoTimer;
  double get multiplierTimer => _multiplierTimer;

  double _spawnTimer = 0;
  double _dieTimer = 0;
  double _pulse = 0;
  ui.Image? _bgImage;

  /// true si la última fila generada tenía monedas de racha: hace que la
  /// próxima fila se dispare mucho más cerca (ver
  /// [GameConstants.coinTrailRowSpacing]) en
  /// vez de esperar el gap normal entre obstáculos, así el patrón se ve
  /// como una línea/cluster conectado en pantalla y no filas sueltas a
  /// cientos de píxeles de distancia.
  bool _lastSpawnWasCoinTrail = false;

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

  /// Techo del área de carriles, en dp lógicos. El canvas sigue a pantalla
  /// completa (bosque a los costados). Lo fija `GameScreen` según breakpoint.
  double maxPlayableWidth = double.infinity;

  void setPlayableMaxWidth(double value) {
    if (maxPlayableWidth == value) return;
    maxPlayableWidth = value;
    if (isLoaded) onGameResize(size);
  }

  double get playableWidth {
    final cap = maxPlayableWidth;
    if (cap.isInfinite) return size.x;
    return size.x < cap ? size.x : cap;
  }

  /// Piso del tamaño visual (jugador, obstáculos, monedas y poderes). Lo
  /// fija `GameScreen`: 1 en celular, 2 en tablet. No se multiplica otra
  /// vez por el ancho de carril. No toca las colisiones.
  double spriteScale = 1;

  void setSpriteScale(double value) {
    if (spriteScale == value) return;
    spriteScale = value;
    if (isLoaded) onGameResize(size);
  }

  /// Carriles tomados de los senderos de tierra del fondo. Antes se repartía el
  /// ancho disponible en tres partes iguales y centradas, así que los carriles
  /// caían sobre los arbustos del arte en vez de sobre la tierra —y el punto de
  /// fuga del PNG no está exactamente en el centro—.
  ({
    double laneWidth,
    double originX,
    double centerX,
    double horizonSpread,
  })? get _backgroundLanes {
    final img = _bgImage;
    if (img == null || size.x <= 0 || size.y <= 0) return null;
    return ForestBackgroundLanes.resolve(
      imageWidth: img.width.toDouble(),
      imageHeight: img.height.toDouble(),
      canvas: Size(size.x, size.y),
      playerY: size.y * GameConstants.playerYFactor,
      laneCount: GameConstants.laneCount,
    );
  }

  /// Centro de convergencia de la perspectiva: el punto de fuga del fondo, no
  /// el centro geométrico de la pantalla.
  double get _laneCenterX => _backgroundLanes?.centerX ?? size.x / 2;

  double get _horizonSpread =>
      _backgroundLanes?.horizonSpread ?? LanePerspective.fallbackHorizonSpread;

  double get _originX =>
      _backgroundLanes?.originX ?? (size.x - playableWidth) / 2;

  double get _laneWidth =>
      _backgroundLanes?.laneWidth ?? playableWidth / GameConstants.laneCount;

  /// Hitbox: acotada a la calibración de celular. Independiente de
  /// [_visualScale] — agrandar sprites no debe cambiar la dificultad ni
  /// solapar filas de racha.
  double get _collisionScale =>
      GameConstants.collisionScaleForLaneWidth(_laneWidth);

  /// Sprite: en celular sigue al carril; en tablet se usa el mayor entre
  /// la escala del carril y [spriteScale] (x2), nunca el producto.
  double get _visualScale {
    final byLane = _laneWidth / GameConstants.referenceLaneWidth;
    final target = spriteScale <= 1 ? byLane : max(byLane, spriteScale);
    return target.clamp(
      GameConstants.minVisualScale,
      GameConstants.maxVisualScale,
    );
  }

  double get _rowHeight => GameConstants.obstacleRowBaseHeight * _visualScale;
  double get _collisionRowHeight =>
      GameConstants.obstacleRowBaseHeight * _collisionScale;
  double get _playerRadius => GameConstants.playerRadius * _collisionScale;
  double get _visualPlayerRadius => GameConstants.playerRadius * _visualScale;

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
    try {
      _bgImage = await Flame.images.load('backgrounds/forest_bg.png');
    } catch (_) {
      _bgImage = null;
    }
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
      sizeScale: _visualScale,
    );
    _warmupSpawns();
  }

  /// Llena las primeras filas "adelantando" el mismo mecanismo de timer que
  /// usa [update] (ver más abajo), en vez de calcular posiciones con una
  /// fórmula aparte. Con dos fórmulas separadas, una fila del burst inicial
  /// y la primera fila generada en vivo podían coincidir en el mismo punto
  /// de la pantalla en el mismo instante — al reusar el timer real no hay
  /// dos relojes que se puedan desincronizar entre sí.
  void _warmupSpawns() {
    const warmupSeconds = 3.5;
    const warmupDt = 1 / 60.0;
    final d0 = curve.difficultyForScore(score);
    final speed0 = curve.scrollSpeed(d0);
    final gap0 = curve.gapSeconds(d0);

    var timer = 0.0;
    var elapsed = 0.0;
    while (elapsed < warmupSeconds) {
      timer += warmupDt;
      final spawnGap =
          _lastSpawnWasCoinTrail
              ? GameConstants.coinTrailRowSpacing / speed0
              : gap0;
      if (timer >= spawnGap) {
        timer = 0;
        // Cuánto ya "recorrió" esta fila entre que se generó (hace
        // warmupSeconds - elapsed) y el instante en que arranca la partida.
        final y = -_rowHeight + speed0 * (warmupSeconds - elapsed);
        _lastSpawnWasCoinTrail = _spawnSegment(initialY: y);
      }
      elapsed += warmupDt;
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
      sizeScale: _visualScale,
    );
    // El motor a veces reporta un tamaño inicial que se corrige un instante
    // después de onLoad(): sin esto, las filas ya generadas quedan ancladas
    // al ancho de carril viejo mientras el jugador salta al nuevo, y
    // obstáculos/monedas terminan visualmente desalineados de la grilla.
    for (final o in _obstacles) {
      o.laneWidth = _laneWidth;
      o.originX = _originX;
      o.centerX = _laneCenterX;
      o.horizonSpread = _horizonSpread;
      o.playerY = player.position.y;
      o.rowHeight = _rowHeight;
      o.collisionHeight = _collisionRowHeight;
    }
    for (final o in _orbs) {
      o.sizeScale = _visualScale;
      // Una moneda que el imán ya está atrayendo dejó su carril a propósito
      // para ir hacia el jugador — reposicionarla acá la manda de vuelta a
      // su carril original y arranca un loop de ida y vuelta con cada
      // resize. Solo reubicamos las que siguen ancladas a su carril.
      if (!o.attracting) {
        o.updateLaneWidth(_laneWidth, _originX);
        o.applyPerspective(player.position.y, _laneCenterX, _horizonSpread);
      }
    }
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
        collisionHeight: _collisionRowHeight,
        color: _currentObstacle,
        centerX: _laneCenterX,
        horizonSpread: _horizonSpread,
        playerY: player.position.y,
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
        sizeScale: _visualScale,
      )..layoutY(y);
      orb.applyPerspective(player.position.y, _laneCenterX, _horizonSpread);
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
        sizeScale: _visualScale,
      )..layoutY(y);
      orb.applyPerspective(player.position.y, _laneCenterX, _horizonSpread);
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
    // Si el frame anterior tardó de más (jank, un frame perdido, volver de
    // background), dt puede llegar mucho más grande de lo normal — y como
    // el imán mueve la moneda a una velocidad fija por segundo, un dt
    // grande se traduce en un salto/teletransporte visible en un solo
    // frame. Con el clamp, como mucho se simula a ~20 fps por frame.
    dt = dt.clamp(0.0, 1 / 20);
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
          orb.attractOffset = Vector2(
            (_fxRng.nextDouble() - 0.5) * 26,
            (_fxRng.nextDouble() - 0.5) * 26,
          );
        }
      }
      if (orb.attracting) {
        final target = player.position + orb.attractOffset;
        final toPlayer = target - orb.position;
        final dist = toPlayer.length;
        if (dist > 1) {
          orb.position += toPlayer.normalized() *
              min(GameConstants.magnetPullSpeed * dt, dist);
        }
      } else {
        orb.position.y += speed * dt;
        orb.applyPerspective(player.position.y, _laneCenterX, _horizonSpread);
      }
    }

    _spawnTimer += dt;
    // Filas de racha se disparan mucho más seguido (distancia fija en vez
    // del gap normal) para que se vean pegadas unas a otras en pantalla.
    final spawnGap =
        _lastSpawnWasCoinTrail
        ? GameConstants.coinTrailRowSpacing / speed
        : gap;
    if (_spawnTimer >= spawnGap) {
      _spawnTimer = 0;
      _lastSpawnWasCoinTrail = _spawnSegment();
    }

    for (final orb in _orbs) {
      if (orb.tryCollect(
        playerLane: player.lane,
        playerX: player.position.x,
        playerY: player.position.y,
        playerRadius: _visualPlayerRadius,
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
        playerRadius: _playerRadius,
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
        obstaclesCleared += 1;
      }
    }
  }

  void _startDeath() {
    if (state != OneGameState.playing) return;
    state = OneGameState.dying;
    _dieTimer = 0;
  }

  /// Fallback usado mientras `assets/images/backgrounds/forest_bg.png` no
  /// terminó de cargar (o si falló la carga).
  void _drawProceduralBg(Canvas canvas, Size screen) {
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
  }

  void _drawGenericBg(Canvas canvas, Size screen) {
    final rect = Offset.zero & screen;
    final img = _bgImage;
    if (img == null || screen.width <= 0 || screen.height <= 0) {
      _drawProceduralBg(canvas, screen);
    } else {
      // Imagen fija, sin scroll: se recorta a lo Cover para llenar la
      // pantalla completa sin deformarla.
      _drawImageCover(canvas, img, rect);

      // Velo de color sutil: mantiene la variedad de matiz por score y da
      // contraste contra obstáculos/HUD sobre el arte fijo.
      canvas.drawRect(rect, Paint()..color = _currentBg.withValues(alpha: 0.16));
    }

    _drawLaneGuides(canvas, screen);

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

  /// Recorta [image] para llenar [dst] por completo (equivalente a
  /// BoxFit.cover), igual que hace ObstacleRowComponent con su sprite.
  void _drawImageCover(Canvas canvas, ui.Image image, Rect dst) {
    final src = ForestBackgroundLanes.coverSrcRect(
      srcWidth: image.width.toDouble(),
      srcHeight: image.height.toDouble(),
      dst: dst.size,
    );
    canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.low);
  }

  /// Líneas divisorias de carril con la misma perspectiva que obstáculos y
  /// monedas: convergen hacia el centro en el horizonte (y = 0) y llegan a
  /// ancho completo a la altura del jugador, sin salto en ese punto.
  void _drawLaneGuides(Canvas canvas, Size screen) {
    final lanePaint = Paint()
      ..color = _currentLane
      ..strokeWidth = 1.4;
    if (!isLoaded) {
      for (var i = 1; i < GameConstants.laneCount; i++) {
        final x = _originX + _laneWidth * i;
        canvas.drawLine(Offset(x, 0), Offset(x, screen.height), lanePaint);
      }
      return;
    }
    final playerY = player.position.y;
    for (var i = 1; i < GameConstants.laneCount; i++) {
      final flatX = _originX + _laneWidth * i;
      final topX = LanePerspective.apply(
        flatX: flatX,
        y: 0,
        playerY: playerY,
        centerX: _laneCenterX,
        horizonSpread: _horizonSpread,
      );
      canvas.drawLine(Offset(topX, 0), Offset(flatX, playerY), lanePaint);
      canvas.drawLine(Offset(flatX, playerY), Offset(flatX, screen.height), lanePaint);
    }
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

    if (isLoaded && (_shieldActive || _shieldFlashTimer > 0)) {
      final flash = _shieldFlashTimer > 0;
      canvas.drawCircle(
        Offset(player.position.x, player.position.y),
        _visualPlayerRadius + (flash ? 10 : 5),
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
      _visualPlayerRadius + extraRadius + a * 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color.withValues(alpha: 0.55 + a * 0.3),
    );
  }
}
