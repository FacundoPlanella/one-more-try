/// Constantes de gameplay y monetización.
/// Tunear dificultad aquí sin tocar el loop de juego.
class GameConstants {
  GameConstants._();

  static const String appName = 'One more try.';
  static const String packageId = 'one.more.try';
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/onemoretry-privacy';
  static const String supportEmail = 'enunfla.contact@gmail.com';

  /// Altura reservada para el banner AdMob + margen (dp lógicos).
  static const double bannerReservedHeight = 64;

  static const int laneCount = 3;
  static const double playerYFactor = 0.72;
  static const double playerRadius = 16;
  static const double laneSwitchDuration = 0.14;
  /// Perdón de hitbox (fracción del ancho de carril).
  static const double hitboxForgiveness = 0.05;

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
  static const int coinPatternLengthMax = 10;

  /// Probabilidad de sumar un carril extra con moneda a cada fila de una
  /// racha (además del carril "espina" del patrón), para que se vean
  /// agrupadas en vez de una única línea prolija. Cada carril extra
  /// adicional en la misma fila es menos probable ([coinTrailExtraLaneDecay]).
  static const double coinTrailExtraLaneChance = 0.5;
  static const double coinTrailExtraLaneDecay = 0.55;

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

  // AdMob — IDs de TEST. Reemplazar en release (ver README).
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
}
