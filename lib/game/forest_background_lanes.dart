import 'dart:ui';

/// Geometría de los tres senderos de tierra de `forest_bg.png` (1080×1920),
/// medida sobre el propio PNG analizando qué columnas son tierra en cada
/// banda de filas.
///
/// El arte tiene perspectiva: el sendero del medio se mantiene fijo en
/// x ≈ 0.511 del ancho, y la separación entre centros de carril crece con la
/// profundidad (más angosta arriba, más ancha abajo). Los carriles del juego se
/// derivan de acá para que caigan sobre la tierra en vez de sobre los arbustos.
class ForestBackgroundLanes {
  ForestBackgroundLanes._();

  /// Centro del carril del medio, en fracción del ancho de la imagen. Es el
  /// punto de fuga horizontal del arte y no se mueve con la profundidad.
  static const double midCenterFraction = 0.511;

  // Dos mediciones de referencia (fracción del ancho de la imagen entre
  // centros de carriles vecinos) con las que se interpola linealmente.
  static const double _refImageY0 = 0.35;
  static const double _refSeparation0 = 0.204;
  static const double _refImageY1 = 0.88;
  static const double _refSeparation1 = 0.323;

  /// Separación entre centros de carril a la altura [imageY] (fracción de la
  /// altura de la imagen), expresada como fracción del ancho de la imagen.
  static double separationAt(double imageY) {
    final t = (imageY - _refImageY0) / (_refImageY1 - _refImageY0);
    final raw = _refSeparation0 + (_refSeparation1 - _refSeparation0) * t;
    // Los extremos del PNG (horizonte y borde inferior) quedan casi siempre
    // fuera del recorte; acotar evita extrapolar hasta valores sin sentido.
    return raw.clamp(0.17, 0.36).toDouble();
  }

  /// Recorte que usa un dibujado tipo `BoxFit.cover` de una imagen
  /// [srcWidth]×[srcHeight] sobre [dst]. Lo comparten el dibujado del fondo y
  /// el cálculo de carriles: si difirieran, los carriles no caerían sobre la
  /// tierra.
  static Rect coverSrcRect({
    required double srcWidth,
    required double srcHeight,
    required Size dst,
  }) {
    final srcAspect = srcWidth / srcHeight;
    final dstAspect = dst.width / dst.height;
    if (srcAspect > dstAspect) {
      final cropWidth = srcHeight * dstAspect;
      return Rect.fromLTWH((srcWidth - cropWidth) / 2, 0, cropWidth, srcHeight);
    }
    final cropHeight = srcWidth / dstAspect;
    return Rect.fromLTWH(0, (srcHeight - cropHeight) / 2, srcWidth, cropHeight);
  }

  /// Ancho de carril, borde izquierdo del área de carriles y punto de fuga, en
  /// píxeles de pantalla, para que los tres carriles coincidan con los senderos
  /// del fondo a la altura del jugador ([playerY]).
  ///
  /// [horizonSpread] es cuánto se angosta el camino en el borde superior
  /// visible respecto de la fila del jugador; depende del recorte, porque en una
  /// pantalla ancha se ve una banda vertical más corta del PNG.
  static ({
    double laneWidth,
    double originX,
    double centerX,
    double horizonSpread,
  }) resolve({
    required double imageWidth,
    required double imageHeight,
    required Size canvas,
    required double playerY,
    required int laneCount,
  }) {
    final src = coverSrcRect(
      srcWidth: imageWidth,
      srcHeight: imageHeight,
      dst: canvas,
    );
    final scale = canvas.width / src.width;
    final playerImageY =
        (src.top + (playerY / canvas.height) * src.height) / imageHeight;
    final separationAtPlayer = separationAt(playerImageY);
    final laneWidth = separationAtPlayer * imageWidth * scale;
    final centerX = (midCenterFraction * imageWidth - src.left) * scale;
    return (
      laneWidth: laneWidth,
      originX: centerX - laneWidth * laneCount / 2,
      centerX: centerX,
      horizonSpread: separationAt(src.top / imageHeight) / separationAtPlayer,
    );
  }
}
