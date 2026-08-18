/// Convierte una X "plana" (grilla de carriles de ancho uniforme) en la X
/// de pantalla que sigue la perspectiva del camino dibujado en
/// `assets/images/backgrounds/forest_bg.png`: angosto cerca del horizonte
/// (y chico, lejos) y a ancho completo a la altura del jugador (y =
/// [playerY]), sin salto visual en el punto donde ocurre la colisión.
class LanePerspective {
  LanePerspective._();

  /// Convergencia usada cuando no se conoce la geometría del fondo (imagen sin
  /// cargar). Con el PNG disponible, el valor real lo calcula
  /// `ForestBackgroundLanes.resolve` midiendo cuánto se angosta el sendero
  /// entre el borde superior visible y la fila del jugador.
  static const double fallbackHorizonSpread = 0.3;

  static double apply({
    required double flatX,
    required double y,
    required double playerY,
    required double centerX,
    double horizonSpread = fallbackHorizonSpread,
  }) {
    final t = playerY <= 0 ? 1.0 : (y / playerY).clamp(0.0, 1.0);
    final spread = horizonSpread + (1.0 - horizonSpread) * t;
    return centerX + (flatX - centerX) * spread;
  }
}
