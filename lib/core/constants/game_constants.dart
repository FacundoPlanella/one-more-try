/// Constantes de gameplay y monetización.
/// Tunear dificultad aquí sin tocar el loop de juego.
class GameConstants {
  GameConstants._();

  static const String appName = 'One more try.';
  static const String packageId = 'one.more.try';
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/onemoretry-privacy';
  static const String supportEmail = 'enunfla.contact@gmail.com';
  /// App Store numeric ID, para el fallback de "Rate this app" en iOS
  /// (in_app_review lo necesita solo si requestReview() no está disponible).
  /// Completar cuando la app se publique en la App Store.
  static const String iosAppStoreId = '';
  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$packageId';

  /// Obstáculos a esquivar durante el tutorial guiado antes de marcarlo
  /// como completado (ver §9.3 del GDD).
  static const int tutorialGuidedObstacles = 3;

  /// Altura reservada para el banner AdMob + margen (dp lógicos).
  static const double bannerReservedHeight = 64;

  static const int laneCount = 3;
  static const double playerYFactor = 0.72;
  static const double playerRadius = 16;
  static const double laneSwitchDuration = 0.14;
  /// Perdón de hitbox (fracción del ancho de carril).
  static const double hitboxForgiveness = 0.05;

  /// Ancho de carril "de diseño": playerRadius, el sprite del jugador, el
  /// alto de fila de obstáculos y el tamaño de los coleccionables están
  /// calibrados a ojo contra este valor. `OneGame` escala esos tamaños en
  /// proporción a `laneWidth actual / referenceLaneWidth` (ver
  /// `OneGame._sizeScale`) para que jugador/obstáculos/coleccionables
  /// guarden siempre la misma proporción entre sí sin importar el ancho de
  /// pantalla real — en este ancho de referencia el resultado es idéntico
  /// al de antes de introducir el escalado.
  static const double referenceLaneWidth = 130;
  static const double minSizeScale = 0.75;

  /// Techo de la hitbox. La colisión en X es por índice de carril, no por
  /// píxeles: agrandar este factor solo estira la ventana vertical. El
  /// espaciado entre filas (gap en segundos, [coinTrailRowSpacing] en px) no
  /// escala con el carril, así que un techo de 2–8 en tablet hacía que dos
  /// filas seguidas se solaparan, se comieran el escudo y dejaran tramos
  /// sin carril libre. 1.2 deja holgura respecto de 110 px y no cambia el
  /// celular (ahí el factor queda en 0.75–0.9).
  static const double maxSizeScale = 1.2;

  /// Alto de diseño de una fila de obstáculos, en px lógicos. La hitbox
  /// vertical usa [obstacleHitHeightFactor] de este valor.
  static const double obstacleRowBaseHeight = 56;
  static const double obstacleHitHeightFactor = 0.52;

  /// Distancia fija entre filas de una racha de monedas. Tiene que ser
  /// mayor que dos radios de hitbox o las cajas se solapan.
  static const double coinTrailRowSpacing = 110;

  /// Escala visual (sprite) independiente de la hitbox. No se apila con el
  /// crecimiento del carril: en tablet se toma el mayor entre la escala del
  /// carril y el x2 pedido, no el producto (eso era ~4× y superponía rocas).
  static const double minVisualScale = 0.9;
  static const double maxVisualScale = 2.6;

  /// Mitad de la ventana vertical de colisión (roca + jugador) a una
  /// [collisionScale] dada. Dos filas a distancia D son jugables solo si
  /// `2 * rowHitHalfExtent(scale) < D`.
  static double rowHitHalfExtent(double collisionScale) {
    final half =
        obstacleRowBaseHeight * collisionScale * obstacleHitHeightFactor / 2;
    final radius = playerRadius * collisionScale * (1 - hitboxForgiveness);
    return half + radius;
  }

  static double collisionScaleForLaneWidth(double laneWidth) {
    return (laneWidth / referenceLaneWidth)
        .clamp(minSizeScale, maxSizeScale)
        .toDouble();
  }

  static const double baseScrollSpeed = 220;
  static const double maxScrollSpeed = 520;
  static const double maxGapSeconds = 2.4;
  static const double minGapSeconds = 0.85;
  static const double difficultyScoreScale = 180;

  static const double scorePerSecond = 1.0;
  static const int orbScore = 1;
  static const int comboEvery = 5;

  static const int warmupSegments = 8;
  static const double breathEveryEasy = 6;
  static const double breathEveryHard = 10;

  /// Peso relativo de cada tipo de pickup cuando se decide spawnear uno
  /// (ver [DifficultyCurve.orbChance] para la probabilidad general de spawn).
  static const double pickupWeightScore = 0.2;
  static const double pickupWeightCoin = 0.55;
  static const double pickupWeightPower = 0.25;

  static const int coinValue = 100;
  /// Bono plano del perk "richer coins" (mismo orden de magnitud que
  /// [coinValue], para que siga sintiéndose como "el doble por moneda").
  static const int richerCoinsBonus = 100;

  /// Cada tantos segmentos (± aleatorio) arranca una racha de monedas en
  /// patrón, además de las monedas sueltas normales. Intervalo corto para
  /// que haya monedas constantemente, una tras otra, durante toda la partida.
  static const int coinTrailEveryMin = 2;
  static const int coinTrailEveryMax = 5;
  static const int coinPatternLengthMin = 2;
  static const int coinPatternLengthMax = 6;

  /// Probabilidad de sumar un carril extra con moneda a cada fila de una
  /// racha (además del carril "espina" del patrón), para que se vean
  /// agrupadas en vez de una única línea prolija. Cada carril extra
  /// adicional en la misma fila es menos probable ([coinTrailExtraLaneDecay]).
  /// Moderado a propósito: con el espaciado apretado de las rachas, un
  /// valor alto acumula demasiadas monedas vivas a la vez (imán las
  /// atrae todas juntas) y eso frena el juego en dispositivos de gama media.
  static const double coinTrailExtraLaneChance = 0.3;
  static const double coinTrailExtraLaneDecay = 0.5;

  /// Cada tantos segmentos (± aleatorio) se garantiza un power-up, sin
  /// importar el sorteo normal — si no, las rachas de moneda ocupan casi
  /// todos los espacios y los poderes casi no aparecen.
  static const int powerGuaranteedEveryMin = 15;
  static const int powerGuaranteedEveryMax = 25;

  static const double magnetSeconds = 6.0;
  /// Velocidad (px/s) a la que una moneda "atraída" viaja hacia el jugador.
  static const double magnetPullSpeed = 480.0;
  static const double slowmoSeconds = 4.0;
  static const double slowmoFactor = 0.6;
  static const double multiplierSeconds = 8.0;

  /// Ventana de invulnerabilidad tras consumir el escudo (evita que el mismo
  /// obstáculo que lo gastó mate al jugador un frame después).
  static const double shieldInvulnSeconds = 0.4;

  // AdMob — IDs de TEST oficiales de Google. AdsService los usa en debug
  // (y en la rama `test`) para no generar tráfico inválido al desarrollar.
  // No reemplazar por IDs reales.
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // AdMob — IDs de PRODUCCIÓN (publicador pub-2433691102754840).
  // AdsService los usa en release de esta rama (`main`). iOS queda vacío
  // hasta publicar en App Store: un ID vacío no cae al de test, oculta el banner.
  static const String androidAppIdProd =
      'ca-app-pub-2433691102754840~1644832695';
  static const String iosAppIdProd = '';
  static const String androidBannerIdProd =
      'ca-app-pub-2433691102754840/7872678161';
  static const String iosBannerIdProd = '';
}
