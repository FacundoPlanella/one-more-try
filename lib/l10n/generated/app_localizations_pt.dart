// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTagline => 'Um toque. Uma vida.';

  @override
  String get play => 'Jogar';

  @override
  String get linkSkins => 'Skins';

  @override
  String get linkShop => 'Loja';

  @override
  String get linkStats => 'Stats';

  @override
  String get linkMedals => 'Medalhas';

  @override
  String get dailyComplete => 'Diária completa';

  @override
  String dailyLabel(String title) {
    return 'Diária: $title';
  }

  @override
  String bestScoreLabel(int score) {
    return 'Melhor $score';
  }

  @override
  String get titleNovice => 'Novato';

  @override
  String get titleApprentice => 'Aprendiz';

  @override
  String get titleSteady => 'Constante';

  @override
  String get titleRecordHunter => 'Caçador de recordes';

  @override
  String get titleMinimalist => 'Minimalista';

  @override
  String get titleOneMore => 'Mais uma';

  @override
  String get titleBalance => 'Equilíbrio';

  @override
  String get titleOneMoreTry => 'One more try.';

  @override
  String get tutorialTitle => 'Toque para trocar de faixa';

  @override
  String get tutorialSubtitle => 'Desvie dos blocos. One more try.';

  @override
  String get tutorialCta => 'Toque em qualquer lugar para começar';

  @override
  String get tutorialSkip => 'Pular';

  @override
  String get tutorialHint => 'Toque em qualquer lugar para trocar de faixa';

  @override
  String get pauseTitle => 'Pausado';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get howToPlaySubtitle => 'Reveja o básico quando quiser';

  @override
  String get rateApp => 'Avaliar o app';

  @override
  String get rateAppSubtitle => 'Está gostando? Deixe sua avaliação';

  @override
  String get contactSupport => 'Contato e feedback';

  @override
  String get contactSupportSubtitle => 'Envie uma sugestão ou reporte um bug';

  @override
  String contactSupportEmailSubject(String appName) {
    return '$appName — feedback';
  }

  @override
  String get gotIt => 'Entendi';

  @override
  String get newBest => 'NOVO RECORDE';

  @override
  String get dailyMissionComplete => 'Missão diária completa';

  @override
  String get medalUnlocked => 'Medalha desbloqueada';

  @override
  String get newSkinUnlocked => 'Nova skin desbloqueada';

  @override
  String titlePrefix(String name) {
    return 'Título: $name';
  }

  @override
  String get playAgain => 'One more try.';

  @override
  String get shareScore => 'Compartilhar pontuação';

  @override
  String shareScoreMessage(int score) {
    return 'Fiz $score pontos em One more try.! Consegue superar?';
  }

  @override
  String get shareGame => 'Compartilhar jogo';

  @override
  String get shareGameMessage =>
      'One more try. — um jogo infinito de um toque só. Experimente!';

  @override
  String get menu => 'Menu';

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
    return 'Melhor pontuação ≥ $n';
  }

  @override
  String unlockHintGames(int n) {
    return '$n partidas';
  }

  @override
  String unlockHintDaily(int n) {
    return '$n missões diárias';
  }

  @override
  String get unlockHintShop => 'Disponível na Loja';

  @override
  String get shopTitle => 'Loja';

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
  String get confirmPurchaseTitle => 'Confirmar compra?';

  @override
  String confirmPurchaseSkinMessage(String name, int price) {
    return 'Você vai comprar $name por $price moedas.';
  }

  @override
  String get perkActiveLabel => 'Ativo — em toda partida';

  @override
  String perkPurchasedSnackbar(String name) {
    return '$name equipado — ativo em toda partida';
  }

  @override
  String skinPurchasedSnackbar(String name) {
    return '$name desbloqueada';
  }

  @override
  String get purchaseFailedSnackbar => 'Não foi possível concluir a compra';

  @override
  String get medalsTitle => 'Medalhas e Títulos';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statBestScore => 'Melhor pontuação';

  @override
  String get statGamesPlayed => 'Partidas jogadas';

  @override
  String get statAverage20 => 'Média (últimas 20)';

  @override
  String get statTimePlayed => 'Tempo jogado';

  @override
  String statMinutes(String n) {
    return '$n min';
  }

  @override
  String get statDistance => 'Distância percorrida';

  @override
  String statMeters(Object n) {
    return '$n m';
  }

  @override
  String get statOrbsCollected => 'Orbes coletados';

  @override
  String get statDaysPlayed => 'Dias jogados';

  @override
  String get statRecordsBeaten => 'Recordes superados';

  @override
  String get statDailyMissions => 'Missões diárias';

  @override
  String get statSkinsUnlocked => 'Skins desbloqueadas';

  @override
  String get statMedals => 'Medalhas';

  @override
  String get statDeathsPerLane => 'Mortes E / C / D';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get music => 'Música';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get haptics => 'Vibração';

  @override
  String get reduceMotion => 'Reduzir movimento';

  @override
  String get theme => 'Tema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get about => 'Sobre';

  @override
  String aboutSubtitle(String appName) {
    return '$appName\nOffline · Somente banners publicitários · v1.0.0';
  }

  @override
  String get credits => 'Créditos';

  @override
  String get creditsSubtitle =>
      'Arte de Shade · Criaturas mitológicas filipinas';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get privacyPolicySubtitle =>
      'O progresso é salvo apenas neste dispositivo. O AdMob pode coletar dados conforme a política do Google.';

  @override
  String get termsAndConditions => 'Termos e condições';

  @override
  String get creditsHeading => 'Créditos';

  @override
  String get pixelArtLabel => 'Pixel art';

  @override
  String get philippineMythCreatures => 'Criaturas mitológicas filipinas';

  @override
  String get byShade => 'por Shade';

  @override
  String get cc0Note => 'CC0 · pacote do itch.io usado com agradecimento';

  @override
  String get viewOnItch => 'Ver no itch.io';

  @override
  String get uiArtLabel => 'Ícones de UI e skins da loja';

  @override
  String get superRetroWorldPack => 'Super Retro World — Character Pack';

  @override
  String get bySuperRetroAuthors => 'por Gif, Noiracide e Romi';

  @override
  String get superRetroLicenseNote =>
      'Uso livre com crédito · pacote do itch.io';

  @override
  String get gameByPlanella => 'One more try. — Planella';

  @override
  String get back => 'Voltar';

  @override
  String get loading => 'Carregando…';

  @override
  String get medalFirstRunName => 'Primeiro pulso';

  @override
  String get medalFirstRunDesc => 'Termine 1 partida';

  @override
  String get medalScore50Name => 'Despertar';

  @override
  String get medalScore50Desc => 'Pontuação ≥ 50';

  @override
  String get medalScore100Name => 'No ritmo';

  @override
  String get medalScore100Desc => 'Pontuação ≥ 100';

  @override
  String get medalScore250Name => 'Foco';

  @override
  String get medalScore250Desc => 'Pontuação ≥ 250';

  @override
  String get medalScore500Name => 'Mestre';

  @override
  String get medalScore500Desc => 'Pontuação ≥ 500';

  @override
  String get medalScore1000Name => 'Lenda';

  @override
  String get medalScore1000Desc => 'Pontuação ≥ 1000';

  @override
  String get medalGames50Name => 'Persistente';

  @override
  String get medalGames50Desc => 'Jogue 50 partidas';

  @override
  String get medalGames200Name => 'Habitual';

  @override
  String get medalGames200Desc => 'Jogue 200 partidas';

  @override
  String get medalDaily3Name => 'Constância';

  @override
  String get medalDaily3Desc => 'Complete 3 missões diárias';

  @override
  String get medalDaily7Name => 'Semana perfeita';

  @override
  String get medalDaily7Desc => 'Complete 7 missões diárias';

  @override
  String get medalNearMissName => 'Quase…';

  @override
  String get medalNearMissDesc => '10 partidas a menos de 10 do seu recorde';

  @override
  String get medalNoCollectName => 'Purista';

  @override
  String get medalNoCollectDesc => 'Pontuação ≥ 150 sem orbes';

  @override
  String get medalCoins100Name => 'Bolsa de moedas';

  @override
  String get medalCoins100Desc => 'Ganhe 10.000 moedas no total';

  @override
  String get medalCoins500Name => 'Tesouraria';

  @override
  String get medalCoins500Desc => 'Ganhe 50.000 moedas no total';

  @override
  String get missionReach80 => 'Chegue a 80 em uma partida';

  @override
  String get missionPlay5 => 'Jogue 5 partidas';

  @override
  String get missionOrbs30 => 'Colete 30 orbes';

  @override
  String get missionSurvive60 => 'Sobreviva 60 segundos';

  @override
  String get missionReach120 => 'Chegue a 120 em uma partida';

  @override
  String get perkBiggerMagnetName => 'Ímã maior';

  @override
  String get perkBiggerMagnetDesc => 'O ímã atrai moedas de mais longe';

  @override
  String get perkStartWithShieldName => 'Bom começo';

  @override
  String get perkStartWithShieldDesc =>
      'Toda partida começa com um escudo ativo';

  @override
  String get perkRicherCoinsName => 'Moedas mais valiosas';

  @override
  String get perkRicherCoinsDesc => 'As moedas valem 100 unidades extra';
}
