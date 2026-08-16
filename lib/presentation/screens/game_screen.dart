import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
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
              pageBuilder: (_, _, _) => ResultScreen(
                score: score,
                coins: coins,
                apply: result,
              ),
              transitionsBuilder: (_, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        });
      },
    );
    _tutorialStage =
        app.save.tutorialDone ? _TutorialStage.none : _TutorialStage.intro;
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

    return BannerScaffold(
      child: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_tutorialStage != _TutorialStage.intro && !_paused)
                        AssetIconButton(
                          asset: 'assets/images/ui/boton_pausa.png',
                          size: 44,
                          tooltip: t.pauseTitle,
                          onPressed: _pauseGame,
                        )
                      else
                        const SizedBox(width: 44, height: 44),
                      Expanded(
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                final multiplierOn = _game.multiplierTimer > 0;
                                return HudCounter(
                                  value: multiplierOn ? '$_score ✖2' : '$_score',
                                  iconAsset: 'assets/images/ui/icono_puntos.png',
                                  width: 150,
                                  valueColor: multiplierOn
                                      ? const Color(0xFFF472B6)
                                      : null,
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            HudCounter(
                              value: '$_coins',
                              iconAsset: 'assets/images/ui/icono_moneda.png',
                              width: 120,
                            ),
                          ],
                        ),
                      ),
                      HudCounter(
                        value: '${app.save.bestScore}',
                        iconAsset: 'assets/images/ui/icono_puntos.png',
                        width: 110,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _PowerBadgeRow(game: _game),
                ],
              ),
            ),
          ),
          if (_tutorialStage == _TutorialStage.guided)
            const _TutorialHintBanner(),
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

class _PowerBadgeRow extends StatelessWidget {
  const _PowerBadgeRow({required this.game});

  final OneGame game;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      if (game.shieldActive) const _PowerBadge('🛡️', Color(0xFF34D399)),
      if (game.magnetTimer > 0) const _PowerBadge('🧲', Color(0xFF60A5FA)),
      if (game.slowmoTimer > 0) const _PowerBadge('🐌', Color(0xFF818CF8)),
      if (game.multiplierTimer > 0) const _PowerBadge('✖2', Color(0xFFF472B6)),
    ];
    if (badges.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (final b in badges) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)],
    );
  }
}

class _PowerBadge extends StatelessWidget {
  const _PowerBadge(this.emoji, this.color);

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.85), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 13)),
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
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: AspectRatio(
                  // Proporción original de panel_pausa.png — no se deforma.
                  aspectRatio: 1122 / 1402,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 44,
                          vertical: 76,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.pauseTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
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
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 200,
                              child: PrimaryButton(
                                label: t.pauseResume,
                                onPressed: widget.onResume,
                                expanded: false,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SecondaryActionButton(
                              label: t.menu,
                              onPressed: widget.onMenu,
                              width: 140,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 26,
                        right: 20,
                        child: PanelCloseButton(
                          tooltip: t.pauseResume,
                          onPressed: widget.onResume,
                        ),
                      ),
                    ],
                  ),
                ),
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
    return Positioned.fill(
      child: GestureDetector(
        onTap: onStart,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: WoodPanel(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.tutorialTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.text0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.tutorialSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(color: colors.text1),
                ),
                const SizedBox(height: 18),
                Text(
                  t.tutorialCta,
                  style: GoogleFonts.manrope(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SecondaryActionButton(
                  label: t.tutorialSkip,
                  onPressed: onSkip,
                  width: 140,
                ),
              ],
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
    return Positioned(
      top: 88,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
