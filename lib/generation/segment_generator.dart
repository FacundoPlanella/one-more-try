import 'dart:math';

import '../core/constants/game_constants.dart';
import 'difficulty.dart';
import 'patterns.dart';
import 'segment.dart';

/// Genera segmentos infinitos con path validation lateral.
class SegmentGenerator {
  SegmentGenerator({
    required this.runSeed,
    this.curve = const DifficultyCurve(),
  }) : _rng = Random(runSeed);

  final int runSeed;
  final DifficultyCurve curve;
  final Random _rng;

  int _index = 0;
  int _lastMask = 0;
  int _sinceBreath = 0;
  int _simulatedLane = 1;

  // Racha de monedas en patrón, independiente del spawn normal de pickups:
  // garantiza que aparezcan seguido y en formación.
  int _coinTrailRemaining = 0;
  int _coinTrailStep = 0;
  CoinPattern _coinTrailPattern = CoinPattern.straightCenter;
  int _segmentsSinceTrail = 0;
  int _nextTrailIn = GameConstants.coinTrailEveryMin;

  // Power-up garantizado cada tantos segmentos, independiente del sorteo
  // normal: si no, las rachas de moneda casi no dejan lugar para que
  // aparezcan poderes.
  int _segmentsSincePower = 0;
  int _nextPowerIn = GameConstants.powerGuaranteedEveryMin;

  /// Tiempo mínimo estimado para cruzar un carril (segundos).
  static const double _laneSwitchTime = GameConstants.laneSwitchDuration + 0.02;

  Segment next(double score) {
    final d = curve.difficultyForScore(score);
    final speed = curve.scrollSpeed(d);
    final gap = curve.gapSeconds(d);
    final tier = _index < GameConstants.warmupSegments
        ? 0
        : curve.patternTier(d, 5);
    final breathEvery = curve.breathEvery(d);

    // Se decide ANTES de elegir la máscara de obstáculos: así, si esta fila
    // es parte de una racha, [_coinTrailMask] puede dejar más carriles
    // libres. Si no, a dificultad alta casi siempre quedaría 1 solo carril
    // libre (el doble bloqueo normal) y nunca habría lugar para agrupar
    // monedas — por eso el cluster solo se veía al principio de la partida.
    final inCoinTrail = _advanceCoinTrail();

    _sinceBreath++;
    if (_sinceBreath >= breathEvery.round() && _index > GameConstants.warmupSegments) {
      _sinceBreath = 0;
      _index++;
      // Respiración: sin obstáculo, todos los carriles libres.
      final picked =
          _choosePickup(free: const [0, 1, 2], d: d, inCoinTrail: inCoinTrail);
      return Segment(
        obstacleMask: 0,
        pickupType: picked.type,
        pickupLane: picked.lane,
        coinLanes: picked.coinLanes,
        isBreath: true,
      );
    }

    var mask = inCoinTrail
        ? _coinTrailMask()
        : PatternLibrary.pickMask(
            rng: _rng,
            tier: tier,
            doubleRate: curve.doubleBlockRate(d),
            previousMask: _lastMask,
            playerLaneHint: _simulatedLane,
          );

    mask = _ensureReachable(
      mask: mask,
      fromLane: _simulatedLane,
      gapSeconds: gap,
      scrollSpeed: speed,
    );

    _lastMask = mask;
    final free = LaneMask.freeLaneIndices(mask);
    // Elige el carril libre más cercano para simular path del jugador.
    _simulatedLane = free.reduce(
      (a, b) => (a - _simulatedLane).abs() <= (b - _simulatedLane).abs() ? a : b,
    );

    final picked = _choosePickup(free: free, d: d, inCoinTrail: inCoinTrail);

    _index++;
    return Segment(
      obstacleMask: mask,
      pickupType: picked.type,
      pickupLane: picked.lane,
      coinLanes: picked.coinLanes,
    );
  }

  /// true si esta fila pertenece a una racha de monedas (continuando una
  /// activa o arrancando una nueva si ya toca). Se llama una sola vez por
  /// fila, antes de elegir la máscara de obstáculos.
  bool _advanceCoinTrail() {
    if (_coinTrailRemaining <= 0) {
      _segmentsSinceTrail++;
      if (_segmentsSinceTrail >= _nextTrailIn) {
        _beginCoinTrail();
      }
    }
    return _coinTrailRemaining > 0;
  }

  /// Máscara liviana para filas de racha: a dificultad alta el generador
  /// normal bloquea 2 carriles casi siempre, lo que dejaría un único carril
  /// libre y mataría el cluster. Acá se prioriza dejar espacio (carril
  /// libre de sobra) para que las monedas se vean agrupadas en cualquier
  /// momento de la partida, no solo al principio.
  int _coinTrailMask() {
    if (_rng.nextDouble() < 0.35) return 0; // fila totalmente libre
    return 1 << _rng.nextInt(3); // un solo obstáculo, 2 carriles libres
  }

  /// Decide el/los pickup(s) del segmento: continúa una racha de monedas en
  /// patrón (ya decidida por [_advanceCoinTrail]), un power-up garantizado,
  /// o si no aplica, hace el sorteo normal por peso ([_rollPickupType]).
  ({PickupType? type, int lane, List<int> coinLanes}) _choosePickup({
    required List<int> free,
    required double d,
    required bool inCoinTrail,
  }) {
    if (free.isEmpty) return (type: null, lane: 1, coinLanes: const []);

    // Avanza siempre (incluso durante una racha de monedas activa): si no,
    // una racha larga "congela" este contador y el power queda pendiente
    // muchos más segmentos de los previstos.
    _segmentsSincePower++;
    final powerDue = _segmentsSincePower >= _nextPowerIn;

    if (inCoinTrail) {
      _coinTrailRemaining--;
      final lanes = _withExtraLanes(
        _patternLanes(_coinTrailPattern, _coinTrailStep, free),
        free,
      );
      _coinTrailStep++;
      return (type: null, lane: 1, coinLanes: lanes);
    }

    if (powerDue) {
      _segmentsSincePower = 0;
      _nextPowerIn = GameConstants.powerGuaranteedEveryMin +
          _rng.nextInt(
            GameConstants.powerGuaranteedEveryMax -
                GameConstants.powerGuaranteedEveryMin +
                1,
          );
      return (
        type: _powerTypes[_rng.nextInt(_powerTypes.length)],
        lane: free[_rng.nextInt(free.length)],
        coinLanes: const [],
      );
    }

    if (_rng.nextDouble() < curve.orbChance(d)) {
      return (
        type: _rollPickupType(),
        lane: free[_rng.nextInt(free.length)],
        coinLanes: const [],
      );
    }
    return (type: null, lane: 1, coinLanes: const []);
  }

  void _beginCoinTrail() {
    _segmentsSinceTrail = 0;
    _nextTrailIn = GameConstants.coinTrailEveryMin +
        _rng.nextInt(
          GameConstants.coinTrailEveryMax - GameConstants.coinTrailEveryMin + 1,
        );
    _coinTrailPattern =
        CoinPattern.values[_rng.nextInt(CoinPattern.values.length)];
    _coinTrailRemaining = GameConstants.coinPatternLengthMin +
        _rng.nextInt(
          GameConstants.coinPatternLengthMax -
              GameConstants.coinPatternLengthMin +
              1,
        );
    _coinTrailStep = 0;
  }

  /// Carril(es) de la fila [step] de un patrón, ajustados al carril libre
  /// más cercano (los obstáculos pueden bloquear el carril "ideal").
  static List<int> _patternLanes(CoinPattern pattern, int step, List<int> free) {
    if (pattern == CoinPattern.twinLines) {
      final left = _snapToFree(0, free);
      final right = _snapToFree(2, free);
      return left == right ? [left] : [left, right];
    }
    return [_snapToFree(_patternLane(pattern, step), free)];
  }

  static int _patternLane(CoinPattern pattern, int step) {
    switch (pattern) {
      case CoinPattern.straightLeft:
        return 0;
      case CoinPattern.straightCenter:
        return 1;
      case CoinPattern.straightRight:
        return 2;
      case CoinPattern.zigzagWide:
        return step.isEven ? 0 : 2;
      case CoinPattern.zigzagLeft:
        return step.isEven ? 0 : 1;
      case CoinPattern.zigzagRight:
        return step.isEven ? 1 : 2;
      case CoinPattern.wave:
        const seq = [0, 1, 2, 1];
        return seq[step % seq.length];
      case CoinPattern.staircaseRight:
        const seq = [0, 1, 2];
        return seq[step % seq.length];
      case CoinPattern.staircaseLeft:
        const seq = [2, 1, 0];
        return seq[step % seq.length];
      case CoinPattern.twinLines:
        return 1; // no se usa: twinLines se resuelve en _patternLanes.
    }
  }

  /// Suma carriles extra (además de la "espina" del patrón) a una fila de
  /// racha, con probabilidad decreciente por carril agregado, para formar
  /// clusters de monedas en vez de una única línea prolija.
  List<int> _withExtraLanes(List<int> lanes, List<int> free) {
    final result = [...lanes];
    var chance = GameConstants.coinTrailExtraLaneChance;
    while (result.length < free.length) {
      if (_rng.nextDouble() >= chance) break;
      final candidates = free.where((l) => !result.contains(l)).toList();
      if (candidates.isEmpty) break;
      result.add(candidates[_rng.nextInt(candidates.length)]);
      chance *= GameConstants.coinTrailExtraLaneDecay;
    }
    return result;
  }

  static int _snapToFree(int desired, List<int> free) {
    return free.reduce(
      (a, b) => (a - desired).abs() <= (b - desired).abs() ? a : b,
    );
  }

  static const List<PickupType> _powerTypes = [
    PickupType.magnet,
    PickupType.shield,
    PickupType.slowmo,
    PickupType.multiplier,
  ];

  /// Elige el tipo de pickup según los pesos relativos en [GameConstants].
  PickupType _rollPickupType() {
    final total = GameConstants.pickupWeightScore +
        GameConstants.pickupWeightCoin +
        GameConstants.pickupWeightPower;
    final roll = _rng.nextDouble() * total;
    if (roll < GameConstants.pickupWeightScore) return PickupType.score;
    if (roll < GameConstants.pickupWeightScore + GameConstants.pickupWeightCoin) {
      return PickupType.coin;
    }
    return _powerTypes[_rng.nextInt(_powerTypes.length)];
  }

  /// Garantiza que exista un carril libre alcanzable a tiempo.
  int _ensureReachable({
    required int mask,
    required int fromLane,
    required double gapSeconds,
    required double scrollSpeed,
  }) {
    var current = mask;
    if (current == LaneMask.all) {
      current = LaneMask.all & ~(1 << fromLane);
    }

    final maxLaneDelta = max(
      1,
      (gapSeconds / _laneSwitchTime).floor(),
    );

    bool reachable(int m) {
      final free = LaneMask.freeLaneIndices(m);
      return free.any((lane) => (lane - fromLane).abs() <= maxLaneDelta);
    }

    if (reachable(current)) return current;

    // Abre el carril actual o el más cercano.
    current = current & ~(1 << fromLane);
    if (current == LaneMask.all) {
      current = 0;
    }
    if (!reachable(current)) {
      current = 0; // fail-safe: open
    }
    return current;
  }
}
