import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/panel_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/perk_catalog.dart';
import '../../domain/progression/progression_service.dart';
import '../../game/one_game.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'result_screen.dart';

/// Etapas del onboarding: [intro] es la tarjeta bloqueante inicial,
/// [guided] deja jugar mostrando una pista persistente durante los primeros
/// obstáculos (ver GameConstants.tutorialGuidedObstacles), [none] es el
/// estado normal de partida.
enum _TutorialStage { none, intro, guided }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;
  int _coins = 0;
  bool _ended = false;
  bool _paused = false;
  late OneGame _game;
  late _TutorialStage _tutorialStage;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    final activePerks = app.save.purchasedPerks
        .map((id) => PerkCatalog.byId(id).effect)
        .toSet();
    _game = OneGame(
      skinId: app.save.equippedSkin,
      accentColor: const Color(0xFF5EEAD4),
      reduceMotion: app.save.reduceMotion,
      activePerks: activePerks,
      onScore: (s) {
        if (!mounted || s == _score) return;
        // Evita setState durante el build del GameWidget/LayoutBuilder.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && s != _score) {
            setState(() => _score = s);
          }
        });
      },
      onOrb: () {
        app.audio.playOrb();
        app.haptics.light();
      },
      onCoin: () {
        app.audio.playOrb();
        app.haptics.light();
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Refleja el valor real acumulado (coinValue, perks, ×2), no la
          // cantidad de toques: si no, el HUD muestra "+1 por moneda" en
          // vez del total real y el número salta recién al terminar.
          if (mounted) setState(() => _coins = _game.coins);
        });
      },
      onTapLane: () {
        app.audio.playTap();
        app.haptics.light();
      },
      onDeath: (score, duration, orbs, coins, lane) {
        if (_ended || !mounted) return;
        _ended = true;
        app.audio.playDie();
        app.haptics.heavy();
        final collected = orbs > 0;
        final result = app.finishRun(
          RunResult(
            score: score,
            durationSec: duration,
            orbsCollected: orbs,
            coinsCollected: coins,
            deathLane: lane,
            collectedAnyOrb: collected,
          ),
        );
        if (result.newBest) app.audio.playBest();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (_, _, _) =>
                  ResultScreen(score: score, coins: coins, apply: result),
              transitionsBuilder: (_, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        });
      },
    );
    _tutorialStage = app.save.tutorialDone
        ? _TutorialStage.none
        : _TutorialStage.intro;
    if (_tutorialStage == _TutorialStage.intro) {
      _game.paused = true;
    }
    // Refresca los indicadores de poder activo (no tienen su propio callback)
    // y, durante el tutorial guiado, chequea si ya se esquivaron suficientes
    // obstáculos para darlo por terminado.
    _hudTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;
      if (_tutorialStage == _TutorialStage.guided &&
          _game.obstaclesCleared >= GameConstants.tutorialGuidedObstacles) {
        _finishTutorial();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    super.dispose();
  }

  void _startGuidedTutorial() {
    setState(() => _tutorialStage = _TutorialStage.guided);
    _game.paused = false;
  }

  void _skipTutorial() {
    _game.paused = false;
    _finishTutorial();
  }

  void _finishTutorial() {
    if (_tutorialStage == _TutorialStage.none) return;
    setState(() => _tutorialStage = _TutorialStage.none);
    context.read<AppController>().completeTutorial();
  }

  /// El botón de pausa se oculta en cuanto `_paused` pasa a true (ver
  /// build()), así que no puede haber un segundo toque en vuelo — no hace
  /// falta un flag de debounce aparte.
  void _pauseGame() {
    if (_paused || _ended) return;
    setState(() => _paused = true);
    _game.paused = true;
  }

  void _resumeGame() {
    if (!_paused) return;
    setState(() => _paused = false);
    _game.paused = false;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final t = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);

    // Altura fija del HUD — bugfix del salto visual al recoger un poder: se
    // calcula acá, una única vez por build, a partir del ANCHO de pantalla y
    // la proporción real de marco_hud_superior_recortado.png (1757×169).
    // Nunca depende de score/monedas/poderes activos, así que el marco (y
    // por lo tanto el área jugable de abajo) nunca cambia de tamaño durante
    // la partida. Techo de ~9% de la altura útil (sin la barra de estado
    // del sistema) para no resultar desproporcionado en pantallas
    // anchas/tablets. Ancho completo del viewport — sin margen lateral: un
    // `Padding` horizontal acá antes dejaba ~16px libres a cada lado, que
    // mostraban el `colors.bg0` (verde oscuro) del Scaffold detrás.
    final hudWidth = mq.size.width;
    final usableHeight = mq.size.height - mq.padding.top;
    final d = context.responsive;
    final maxHud = usableHeight * 0.13;
    // El piso escala con [uiScale], no con un valor fijo: los números viven en
    // zonas talladas cuyo alto es una fracción del marco y se ajustan con
    // `FittedBox`, así que el marco es lo único que puede agrandarlos. Con 52/64
    // fijos, en tablet quedaba tan bajo como en un celular y por eso el puntaje,
    // las monedas y el récord se leían diminutos. El estiramiento vertical
    // respecto de la proporción nativa queda igual que en celular (~1.5x).
    // En un viewport muy bajo (ventana de escritorio, tablet apaisada) el piso
    // puede superar al techo; ahí manda el techo, si no `clamp` recibiría los
    // límites invertidos y tiraría ArgumentError en cada frame.
    final minHud = math.min(d.scaledSize(52), maxHud);
    final frameHeight = (hudWidth / _GameHud.contentAspectRatio)
        .clamp(minHud, maxHud)
        .toDouble();

    _game.setPlayableMaxWidth(d.playableMaxWidth);
    _game.setSpriteScale(d.gameSpriteScale);

    // Poderes activos — se dibujan FUERA del marco (overlay flotando sobre
    // el área jugable, no dentro de la zona de puntaje): al vivir como
    // hermanos del Column en este Stack raíz, en vez de adentro de
    // `_GameHud`, no pueden afectar el alto fijo del HUD sea cual sea la
    // cantidad de poderes activos (0 a 3) — un `Positioned` nunca cambia el
    // tamaño de un `Stack`, solo sus hijos sin posicionar (acá, el Column).
    final badges = <Widget>[
      if (_game.shieldActive) const _PowerBadge('🛡️', Color(0xFF34D399)),
      if (_game.magnetTimer > 0) const _PowerBadge('🧲', Color(0xFF60A5FA)),
      if (_game.slowmoTimer > 0) const _PowerBadge('🐌', Color(0xFF818CF8)),
    ];

    return BannerScaffold(
      constrainWidth: false,
      safeTop: false,
      child: Stack(
        children: [
          // HUD y área jugable como regiones separadas de un Column (en vez
          // de dos capas superpuestas del mismo Stack): así el canvas de
          // Flame recibe como `size` únicamente el espacio que queda debajo
          // del HUD, y ningún obstáculo/coleccionable puede spawnear ni
          // scrollear detrás de los contadores. El banner de anuncios ya
          // vive fuera de este `child` (ver BannerScaffold), así que las
          // tres regiones (HUD / juego / anuncio) quedan separadas en la
          // jerarquía de widgets, no solo por z-order.
          Column(
            children: [
              SafeArea(
                // Único responsable del inset superior — antes había,
                // además, un `top: 6` acá mismo, así que el inset se
                // aplicaba dos veces (SafeArea + padding manual) y ese hueco
                // extra dejaba ver `colors.bg0` (verde oscuro) encima del
                // marco. El HUD ahora arranca en 0, pegado al límite
                // superior útil que ya resuelve SafeArea. `left`/`right` en
                // false a propósito: en portrait no hay notch lateral que
                // resolver, y así el ancho del HUD no se acota dos veces
                // (SafeArea horizontal + el propio ancho ya completo).
                bottom: false,
                left: false,
                right: false,
                child: _GameHud(
                  width: hudWidth,
                  frameHeight: frameHeight,
                  pauseVisible:
                      _tutorialStage != _TutorialStage.intro && !_paused,
                  onPause: _pauseGame,
                  pauseTooltip: t.pauseTitle,
                  score: _score,
                  multiplierOn: _game.multiplierTimer > 0,
                  coins: _coins,
                  bestScore: app.save.bestScore,
                  bestLabel: t.statBestScore,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ScreenBackground(
                        'assets/images/backgrounds/forest_bg.png',
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    ClipRect(
                      child: Stack(
                        children: [
                          GameWidget(game: _game),
                          if (_tutorialStage == _TutorialStage.guided)
                            const _TutorialHintBanner(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Separador (separador_hud_gameplay.png) — tapa la costura entre
          // el borde inferior del HUD y el fondo del bosque. Vive acá, como
          // hermano del Column (no adentro de él), por lo mismo que los
          // badges de poderes: así nunca puede afectar la altura fija del
          // HUD ni desplazar el área jugable. Se dibuja ENCIMA de
          // `GameWidget` (después en la lista de hijos del Stack) para que
          // se vea completo — Flame es un único widget opaco, así que no
          // hay forma de intercalarlo "debajo de obstáculos/monedas pero
          // arriba del fondo" dentro de su propio canvas; en la práctica no
          // choca con el gameplay porque nada spawnea en esos ~3px
          // superiores. `IgnorePointer` para no robarle el tap-to-switch-
          // lane al juego.
          Positioned(
            top: mq.padding.top + frameHeight - 3,
            left: 0,
            width: hudWidth,
            height: hudWidth / (2127 / 61),
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/ui/separador_hud_gameplay.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          // Franja de poderes activos, flotando debajo del marco — ver nota
          // arriba. Solo se agrega al árbol cuando hay algo que mostrar: un
          // `Positioned` no reserva espacio propio en el `Stack`, así que
          // no hace falta un contenedor de tamaño fijo para "reservar"
          // nada acá.
          if (badges.isNotEmpty)
            Positioned(
              top: mq.padding.top + frameHeight + 4,
              left: _GameHud._scoreL * hudWidth,
              width: (_GameHud._scoreR - _GameHud._scoreL) * hudWidth,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final b in badges)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: b,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_tutorialStage == _TutorialStage.intro)
            _TutorialIntroCard(
              onStart: _startGuidedTutorial,
              onSkip: _skipTutorial,
            ),
          if (_paused)
            _PauseOverlay(
              onResume: _resumeGame,
              onMenu: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

/// HUD superior de gameplay (marco_hud_superior_recortado.png): pausa +
/// puntaje + monedas + mejor puntaje sobre el marco de madera. Los
/// power-ups activos se dibujan FUERA de este widget (overlay propio en el
/// `Stack` raíz de `GameScreen`, ver `build()` ahí) para que el alto total
/// del HUD sea siempre exactamente el alto del marco, sin importar cuántos
/// poderes estén activos.
///
/// Bugfix del salto visual al recoger un poder: antes, una fila de badges
/// se agregaba/quitaba como hijo condicional de un `Column` sin altura
/// fija, así que el HUD entero crecía y empujaba/achicaba el área jugable
/// de abajo. Acá [width] y [frameHeight] determinan el tamaño total UNA
/// sola vez, a partir del ancho de pantalla — nunca del estado de la
/// partida — y todo el contenido se dibuja con `Positioned` dentro de ese
/// tamaño ya fijado.
class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.width,
    required this.frameHeight,
    required this.pauseVisible,
    required this.onPause,
    required this.pauseTooltip,
    required this.score,
    required this.multiplierOn,
    required this.coins,
    required this.bestScore,
    required this.bestLabel,
  });

  final double width;
  final double frameHeight;
  final bool pauseVisible;
  final VoidCallback onPause;
  final String pauseTooltip;
  final int score;
  final bool multiplierOn;
  final int coins;
  final int bestScore;
  final String bestLabel;

  // marco_hud_superior_recortado.png (1757×169) ya viene recortado al bbox
  // opaco real — sin relleno transparente arriba/abajo que compensar, así
  // que se dibuja directo con esta proporción exacta (`BoxFit.fill` no
  // deforma nada porque el cuadro que le damos ya respeta esta relación).
  static const contentAspectRatio = 1757 / 169;

  // Zonas talladas dentro de la barra — círculo de pausa + 3 rectángulos
  // (puntaje, monedas, mejor puntaje), medidas como fracción del PNG ya
  // recortado (mismas proporciones que el marco anterior, que ya estaban
  // normalizadas a su bbox de contenido).
  static const _slotTop = 0.2381;
  static const _slotBottom = 0.7679;
  static const _pauseL = 0.0330, _pauseR = 0.0831;
  static const _scoreL = 0.1196, _scoreR = 0.3537;
  static const _coinsL = 0.3907, _coinsR = 0.6390;
  static const _bestL = 0.6754, _bestR = 0.9647;

  @override
  Widget build(BuildContext context) {
    final zoneTop = _slotTop * frameHeight;
    final zoneHeight = (_slotBottom - _slotTop) * frameHeight;

    Widget zone(double l, double r, Widget child) {
      return Positioned(
        left: l * width,
        top: zoneTop,
        width: (r - l) * width,
        height: zoneHeight,
        child: child,
      );
    }

    return SizedBox(
      width: width,
      height: frameHeight,
      child: Stack(
        children: [
          // Marco de fondo — el PNG ya viene recortado a su contenido real,
          // así que se dibuja directo sin offsets ni ClipRect adicionales
          // (eso evita cualquier desajuste de sub-píxel entre el recorte y
          // el cuadro final, que era la causa más probable de la línea
          // blanca que se veía con la técnica de recorte anterior).
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/marco_hud_superior_recortado.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          zone(
            _pauseL,
            _pauseR,
            Center(
              child: _HudPauseButton(
                visible: pauseVisible,
                onPressed: onPause,
                tooltip: pauseTooltip,
                slotSize: zoneHeight,
              ),
            ),
          ),
          zone(
            _scoreL,
            _scoreR,
            _HudZoneNumber(
              iconAsset: 'assets/images/ui/icono_puntos.png',
              value: multiplierOn ? '$score ✖2' : '$score',
              color: multiplierOn ? const Color(0xFFF472B6) : Colors.white,
              fontSize: context.responsive.scaledFont(24, min: 18),
              iconSize: context.responsive.scaledSize(22, min: 18),
            ),
          ),
          zone(
            _coinsL,
            _coinsR,
            _HudZoneNumber(
              iconAsset: 'assets/images/ui/icono_moneda.png',
              value: '$coins',
              color: Colors.white,
              fontSize: context.responsive.scaledFont(18, min: 16),
              iconSize: context.responsive.scaledSize(18, min: 16),
            ),
          ),
          zone(
            _bestL,
            _bestR,
            _HudZoneBest(
              iconAsset: 'assets/images/ui/icono_puntos.png',
              value: '$bestScore',
              label: bestLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de pausa dentro del círculo tallado del marco. El ícono se dibuja
/// al tamaño real del slot (para no desbordar el grabado circular), pero el
/// área táctil nunca baja de 44dp — mismo mínimo de toque que el resto de
/// la app — centrada en el mismo punto aunque el ícono visual sea más chico.
class _HudPauseButton extends StatefulWidget {
  const _HudPauseButton({
    required this.visible,
    required this.onPressed,
    required this.tooltip,
    required this.slotSize,
  });

  final bool visible;
  final VoidCallback onPressed;
  final String tooltip;
  final double slotSize;

  @override
  State<_HudPauseButton> createState() => _HudPauseButtonState();
}

class _HudPauseButtonState extends State<_HudPauseButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    final tapSize = math.max(
      context.responsive.isPhone ? 48.0 : 64.0,
      widget.slotSize,
    );
    final iconSize = widget.slotSize * 0.82;
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: SizedBox(
          width: tapSize,
          height: tapSize,
          child: Center(
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              child: Opacity(
                opacity: _pressed ? 0.85 : 1.0,
                child: Image.asset(
                  'assets/images/ui/boton_pausa.png',
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenido de una zona simple (puntaje o monedas): ícono + valor en una
/// fila, todo dentro de un `FittedBox` que se achica si hace falta en vez
/// de desbordar o recortarse.
class _HudZoneNumber extends StatelessWidget {
  const _HudZoneNumber({
    required this.iconAsset,
    required this.value,
    required this.color,
    this.fontSize = 18,
    this.iconSize = 18,
  });

  final String iconAsset;
  final String value;
  final Color color;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconAsset, width: iconSize, height: iconSize),
            const SizedBox(width: 5),
            Text(
              value,
              maxLines: 1,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                color: color,
                shadows: const [
                  Shadow(
                    color: Color(0xCC1B0F06),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido de la zona de mejor puntaje: ícono + valor arriba, etiqueta
/// "Best score" (traducida) abajo — ambas líneas dentro del mismo
/// `FittedBox`, así la etiqueta queda dentro del marco (nunca debajo) sin
/// importar cuánto haya que achicarla para que entre.
class _HudZoneBest extends StatelessWidget {
  const _HudZoneBest({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconAsset,
                  width: context.responsive.scaledSize(19, min: 16),
                  height: context.responsive.scaledSize(19, min: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: context.responsive.scaledFont(20, min: 16),
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0xCC1B0F06),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              label,
              maxLines: 1,
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: context.responsive.scaledFont(12, min: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerBadge extends StatelessWidget {
  const _PowerBadge(this.emoji, this.color);

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final d = context.responsive;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: d.scaledSize(6),
        vertical: d.scaledSize(2),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.85), width: 1.2),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: d.scaledFont(11, min: 11)),
      ),
    );
  }
}

/// Interfaz de pausa: aparece cuando el jugador toca el botón de pausa
/// (boton_pausa.png). El propio juego ya está detenido (`_game.paused`) al
/// montarse este overlay, así que "Resume" es lo único que reactiva el
/// loop. "Menu" corta la partida y vuelve al Home.
class _PauseOverlay extends StatefulWidget {
  const _PauseOverlay({required this.onResume, required this.onMenu});

  final VoidCallback onResume;
  final VoidCallback onMenu;

  @override
  State<_PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<_PauseOverlay> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const aspectRatio = 1122 / 1402;
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final panel = PanelMetrics.resolve(
                    context,
                    constraints: constraints,
                    designWidth: 320,
                    designHeight: 320 / aspectRatio,
                    aspectRatio: aspectRatio,
                  );
                  final s = panel.scale;
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: panel.maxWidth,
                      maxHeight: panel.maxHeight,
                    ),
                    child: AspectRatio(
                      // Proporción original de panel_pausa.png — no se
                      // deforma.
                      aspectRatio: aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/ui/panel_pausa.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 44 * s,
                              vertical: 76 * s,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.pauseTitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 24 * s,
                                    fontWeight: FontWeight.w800,
                                    color: woodPlateTextPrimary,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xCC1B0F06),
                                        offset: Offset(0, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20 * s),
                                SizedBox(
                                  width: 200 * s,
                                  child: PrimaryButton(
                                    label: t.pauseResume,
                                    onPressed: widget.onResume,
                                    expanded: false,
                                    maxWidth: 200 * s,
                                  ),
                                ),
                                SizedBox(height: 8 * s),
                                SecondaryActionButton(
                                  label: t.menu,
                                  onPressed: widget.onMenu,
                                  width: 140 * s,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 26 * s,
                            right: 20 * s,
                            child: PanelCloseButton(
                              tooltip: t.pauseResume,
                              tapSize: 44 * s,
                              iconSize: 30 * s,
                              onPressed: widget.onResume,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialIntroCard extends StatelessWidget {
  const _TutorialIntroCard({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    final d = context.responsive;
    return Positioned.fill(
      child: GestureDetector(
        onTap: onStart,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          padding: EdgeInsets.all(d.scaledSize(32)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: d.scaledSize(420)),
            child: WoodPanel(
              padding: EdgeInsets.symmetric(
                horizontal: d.scaledSize(24),
                vertical: d.scaledSize(26),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.tutorialTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: d.scaledFont(26, min: 26),
                      fontWeight: FontWeight.w800,
                      color: colors.text0,
                    ),
                  ),
                  SizedBox(height: d.scaledSize(10)),
                  Text(
                    t.tutorialSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: colors.text1,
                      fontSize: d.scaledFont(14, min: 14),
                    ),
                  ),
                  SizedBox(height: d.scaledSize(18)),
                  Text(
                    t.tutorialCta,
                    style: GoogleFonts.manrope(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: d.scaledFont(14, min: 14),
                    ),
                  ),
                  SizedBox(height: d.scaledSize(12)),
                  SecondaryActionButton(
                    label: t.tutorialSkip,
                    onPressed: onSkip,
                    width: d.scaledSize(140),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pista no bloqueante que queda visible durante los primeros obstáculos
/// del tutorial guiado: el jugador ya está jugando, solo se refuerza el
/// gesto con feedback hands-on en vez de otro texto estático.
class _TutorialHintBanner extends StatelessWidget {
  const _TutorialHintBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    // Vive dentro del área jugable (el `Expanded` debajo del HUD en
    // build() de GameScreen), que ya empieza por debajo del HUD y de la
    // safe area de arriba — a diferencia de antes, este Positioned ya no
    // comparte coordenadas con el HUD, así que alcanza con un margen chico
    // y fijo en vez de tener que "saltar" manualmente su altura.
    final d = context.responsive;
    return Positioned(
      top: 12,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: d.scaledSize(16),
            vertical: d.scaledSize(8),
          ),
          decoration: BoxDecoration(
            color: colors.bg1.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
          ),
          child: Text(
            t.tutorialHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: colors.text0,
              fontWeight: FontWeight.w600,
              fontSize: d.scaledFont(13, min: 13),
            ),
          ),
        ),
      ),
    );
  }
}
