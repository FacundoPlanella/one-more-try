/// Convierte una X "plana" (grilla de carriles de ancho uniforme) en la X
/// de pantalla que sigue la perspectiva del camino dibujado en
/// `assets/images/backgrounds/forest_bg.png`: angosto cerca del horizonte
/// (y chico, lejos) y a ancho completo a la altura del jugador (y =
/// [playerY]), sin salto visual en el punto donde ocurre la colisión.
class LanePerspective {
  LanePerspective._();

  /// Fracción del ancho total que ocupan los carriles en el horizonte
  /// (y = 0), calibrada a ojo contra lo angosto que se ve el camino en el
  /// fondo. 1.0 anularía el efecto (carriles siempre a ancho completo).
  static const double horizonSpread = 0.3;

  static double apply({
    required double flatX,
    required double y,
    required double playerY,
    required double screenWidth,
  }) {
    final center = screenWidth / 2;
    final t = playerY <= 0 ? 1.0 : (y / playerY).clamp(0.0, 1.0);
    final spread = horizonSpread + (1.0 - horizonSpread) * t;
    return center + (flatX - center) * spread;
  }
}
