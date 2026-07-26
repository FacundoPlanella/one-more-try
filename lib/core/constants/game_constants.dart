/// Constantes de gameplay y monetización.
/// Tunear dificultad aquí sin tocar el loop de juego.
class GameConstants {
  GameConstants._();

  static const String appName = 'One more try.';
  static const String packageId = 'com.studio.onemoretry.game';

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

  // AdMob — IDs de TEST. Reemplazar en release (ver README).
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
}
