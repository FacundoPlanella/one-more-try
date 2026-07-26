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

class Segment {
  const Segment({
    required this.obstacleMask,
    this.hasOrb = false,
    this.orbLane = 1,
    this.isBreath = false,
  });

  /// Bits de carriles bloqueados. 0 = sin obstáculo.
  final int obstacleMask;
  final bool hasOrb;
  final int orbLane;
  final bool isBreath;

  bool get hasObstacle => obstacleMask != 0;
}
