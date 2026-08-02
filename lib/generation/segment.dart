/// Máscaras de carril: L=1, C=2, R=4. Siempre debe quedar ≥1 carril libre.
class LaneMask {
  static const int left = 1;
  static const int center = 2;
  static const int right = 4;
  static const int all = left | center | right;

  static bool isBlocked(int mask, int lane) {
    final bit = 1 << lane;
    return (mask & bit) != 0;
  }

  static int freeLanes(int mask) => all & ~mask;

  static List<int> freeLaneIndices(int mask) {
    final out = <int>[];
    for (var i = 0; i < 3; i++) {
      if (!isBlocked(mask, i)) out.add(i);
    }
    return out;
  }
}

/// Tipo de pelotita coleccionable en pista.
enum PickupType { score, coin, magnet, shield, slowmo, multiplier }

extension PickupTypeIsPower on PickupType {
  bool get isPower => this != PickupType.score && this != PickupType.coin;
}

/// Forma de una racha de monedas consecutivas a lo largo de varios segmentos
/// (largo variable). Todas menos [twinLines] ponen una moneda por fila;
/// [twinLines] pone dos (izquierda + derecha, con el centro libre).
enum CoinPattern {
  straightLeft,
  straightCenter,
  straightRight,
  zigzagWide,
  zigzagLeft,
  zigzagRight,
  wave,
  staircaseRight,
  staircaseLeft,
  twinLines,
}

class Segment {
  const Segment({
    required this.obstacleMask,
    this.pickupType,
    this.pickupLane = 1,
    this.coinLanes = const [],
    this.isBreath = false,
  });

  /// Bits de carriles bloqueados. 0 = sin obstáculo.
  final int obstacleMask;
  final PickupType? pickupType;
  final int pickupLane;

  /// Monedas simultáneas en esta fila (carriles libres), usado por las
  /// rachas de moneda para formar clusters. Independiente de [pickupType].
  final List<int> coinLanes;
  final bool isBreath;

  bool get hasObstacle => obstacleMask != 0;
  bool get hasPickup => pickupType != null;
  bool get hasCoinLanes => coinLanes.isNotEmpty;
}
