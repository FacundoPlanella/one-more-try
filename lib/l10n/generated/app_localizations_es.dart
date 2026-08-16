// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Un toque. Una vida.';

  @override
  String get play => 'Jugar';

  @override
  String get linkSkins => 'Skins';

  @override
  String get linkShop => 'Tienda';

  @override
  String get linkStats => 'Stats';

  @override
  String get linkMedals => 'Medallas';

  @override
  String get dailyComplete => 'Diaria completa';

  @override
  String dailyLabel(String title) {
    return 'Diaria: $title';
  }

  @override
  String bestScoreLabel(int score) {
    return 'Mejor $score';
  }

  @override
  String get titleNovice => 'Novato';

  @override
  String get titleApprentice => 'Aprendiz';

  @override
  String get titleSteady => 'Constante';

  @override
  String get titleRecordHunter => 'Cazarrécords';

  @override
  String get titleMinimalist => 'Minimalista';

  @override
  String get titleOneMore => 'Uno más';

  @override
  String get titleBalance => 'Equilibrio';

  @override
  String get titleOneMoreTry => 'One more try.';

  @override
  String get tutorialTitle => 'Tocá para cambiar de carril';

  @override
  String get tutorialSubtitle => 'Esquivá los bloques. One more try.';

  @override
  String get tutorialCta => 'Tocá en cualquier lado para empezar';

  @override
  String get tutorialSkip => 'Omitir';

  @override
  String get tutorialHint => 'Tocá en cualquier lado para cambiar de carril';

  @override
  String get pauseTitle => 'Pausa';

  @override
  String get pauseResume => 'Reanudar';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get howToPlaySubtitle => 'Repasá lo básico cuando quieras';

  @override
  String get rateApp => 'Calificar la app';

  @override
  String get rateAppSubtitle => '¿Te está gustando? Dejá tu reseña';

  @override
  String get contactSupport => 'Contacto y feedback';

  @override
  String get contactSupportSubtitle =>
      'Mandanos una sugerencia o reportá un bug';

  @override
  String get gotIt => 'Entendido';

  @override
  String get newBest => 'NUEVO RÉCORD';

  @override
  String get dailyMissionComplete => 'Misión diaria completa';

  @override
  String get medalUnlocked => 'Medalla desbloqueada';

  @override
  String get newSkinUnlocked => 'Nueva skin desbloqueada';

  @override
  String titlePrefix(String name) {
    return 'Título: $name';
  }

  @override
  String get playAgain => 'One more try.';

  @override
  String get shareScore => 'Compartir puntaje';

  @override
  String shareScoreMessage(int score) {
    return '¡Saqué $score puntos en One more try.! ¿Podés superarlo?';
  }

  @override
  String get shareGame => 'Compartir juego';

  @override
  String get shareGameMessage =>
      'One more try. — un juego de un solo toque, sin fin. ¡Probalo!';

  @override
  String get menu => 'Menú';

  @override
  String get skinsTitle => 'Skins';

  @override
  String get equipped => 'Equipada';

  @override
  String get unlocked => 'Desbloqueada';

  @override
  String get equip => 'Equipar';

  @override
  String unlockHintScore(int n) {
    return 'Mejor puntaje ≥ $n';
  }

  @override
  String unlockHintGames(int n) {
    return '$n partidas';
  }

  @override
  String unlockHintDaily(int n) {
    return '$n misiones diarias';
  }

  @override
  String get shopTitle => 'Tienda';

  @override
  String get sectionSkins => 'Skins';

  @override
  String get sectionPerks => 'Perks';

  @override
  String get owned => 'Comprada';

  @override
  String get buy => 'Comprar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmPurchaseTitle => '¿Confirmar compra?';

  @override
  String confirmPurchaseSkinMessage(String name, int price) {
    return 'Vas a comprar $name por $price monedas.';
  }

  @override
  String get perkActiveLabel => 'Activo — en cada partida';

  @override
  String perkPurchasedSnackbar(String name) {
    return '$name equipado — activo en cada partida';
  }

  @override
  String skinPurchasedSnackbar(String name) {
    return '$name desbloqueada';
  }

  @override
  String get purchaseFailedSnackbar => 'No se pudo completar la compra';

  @override
  String get medalsTitle => 'Medallas y Títulos';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statBestScore => 'Mejor puntaje';

  @override
  String get statGamesPlayed => 'Partidas jugadas';

  @override
  String get statAverage20 => 'Promedio (últimas 20)';

  @override
  String get statTimePlayed => 'Tiempo jugado';

  @override
  String statMinutes(String n) {
    return '$n min';
  }

  @override
  String get statDistance => 'Distancia recorrida';

  @override
  String statMeters(Object n) {
    return '$n m';
  }

  @override
  String get statOrbsCollected => 'Orbes recolectados';

  @override
  String get statDaysPlayed => 'Días jugados';

  @override
  String get statRecordsBeaten => 'Récords superados';

  @override
  String get statDailyMissions => 'Misiones diarias';

  @override
  String get statSkinsUnlocked => 'Skins desbloqueadas';

  @override
  String get statMedals => 'Medallas';

  @override
  String get statDeathsPerLane => 'Muertes I / C / D';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get music => 'Música';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get haptics => 'Vibración';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get theme => 'Tema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get about => 'Acerca de';

  @override
  String aboutSubtitle(String appName) {
    return '$appName\nSin conexión · Solo banners publicitarios · v1.0.0';
  }

  @override
  String get credits => 'Créditos';

  @override
  String get creditsSubtitle =>
      'Arte de Shade · Criaturas mitológicas filipinas';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicySubtitle =>
      'El progreso se guarda solo en este dispositivo. AdMob puede recolectar datos según la política de Google.';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get creditsHeading => 'Créditos';

  @override
  String get pixelArtLabel => 'Pixel art';

  @override
  String get philippineMythCreatures => 'Criaturas mitológicas filipinas';

  @override
  String get byShade => 'por Shade';

  @override
  String get cc0Note => 'CC0 · pack de itch.io usado con agradecimiento';

  @override
  String get viewOnItch => 'Ver en itch.io';

  @override
  String get uiArtLabel => 'Íconos de UI y skins de tienda';

  @override
  String get superRetroWorldPack => 'Super Retro World — Character Pack';

  @override
  String get bySuperRetroAuthors => 'por Gif, Noiracide y Romi';

  @override
  String get superRetroLicenseNote => 'Uso libre con crédito · pack de itch.io';

  @override
  String get gameByPlanella => 'One more try. — Planella';

  @override
  String get back => 'Volver';

  @override
  String get loading => 'Cargando…';

  @override
  String get medalFirstRunName => 'Primer pulso';

  @override
  String get medalFirstRunDesc => 'Terminá 1 partida';

  @override
  String get medalScore50Name => 'Despertar';

  @override
  String get medalScore50Desc => 'Puntaje ≥ 50';

  @override
  String get medalScore100Name => 'En ritmo';

  @override
  String get medalScore100Desc => 'Puntaje ≥ 100';

  @override
  String get medalScore250Name => 'Foco';

  @override
  String get medalScore250Desc => 'Puntaje ≥ 250';

  @override
  String get medalScore500Name => 'Maestro';

  @override
  String get medalScore500Desc => 'Puntaje ≥ 500';

  @override
  String get medalScore1000Name => 'Leyenda';

  @override
  String get medalScore1000Desc => 'Puntaje ≥ 1000';

  @override
  String get medalGames50Name => 'Persistente';

  @override
  String get medalGames50Desc => 'Jugá 50 partidas';

  @override
  String get medalGames200Name => 'Habitual';

  @override
  String get medalGames200Desc => 'Jugá 200 partidas';

  @override
  String get medalDaily3Name => 'Constancia';

  @override
  String get medalDaily3Desc => 'Completá 3 misiones diarias';

  @override
  String get medalDaily7Name => 'Semana perfecta';

  @override
  String get medalDaily7Desc => 'Completá 7 misiones diarias';

  @override
  String get medalNearMissName => 'Casi…';

  @override
  String get medalNearMissDesc => '10 partidas a menos de 10 de tu récord';

  @override
  String get medalNoCollectName => 'Purista';

  @override
  String get medalNoCollectDesc => 'Puntaje ≥ 150 sin orbes';

  @override
  String get medalCoins100Name => 'Bolsa de monedas';

  @override
  String get medalCoins100Desc => 'Ganá 10.000 monedas en total';

  @override
  String get medalCoins500Name => 'Tesorería';

  @override
  String get medalCoins500Desc => 'Ganá 50.000 monedas en total';

  @override
  String get missionReach80 => 'Llegá a 80 en una partida';

  @override
  String get missionPlay5 => 'Jugá 5 partidas';

  @override
  String get missionOrbs30 => 'Recolectá 30 orbes';

  @override
  String get missionSurvive60 => 'Sobreviví 60 segundos';

  @override
  String get missionReach120 => 'Llegá a 120 en una partida';

  @override
  String get perkBiggerMagnetName => 'Imán más grande';

  @override
  String get perkBiggerMagnetDesc => 'El imán atrae monedas desde más lejos';

  @override
  String get perkStartWithShieldName => 'Buen comienzo';

  @override
  String get perkStartWithShieldDesc =>
      'Cada partida empieza con un escudo activo';

  @override
  String get perkRicherCoinsName => 'Monedas de más valor';

  @override
  String get perkRicherCoinsDesc => 'Las monedas valen 100 unidades extra';
}
