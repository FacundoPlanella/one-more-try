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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
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
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: colors.text1),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                final multiplierOn = _game.multiplierTimer > 0;
                                return AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: GoogleFonts.outfit(
                                    fontSize: multiplierOn ? 42 : 36,
                                    fontWeight: FontWeight.w700,
                                    color: multiplierOn
                                        ? const Color(0xFFF472B6)
                                        : colors.text0,
                                  ),
                                  child: Text(
                                    multiplierOn ? '$_score  ✖2' : '$_score',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                            CoinLabel(
                              amount: _coins,
                              iconSize: 14,
                              style: GoogleFonts.manrope(
                                color: colors.text1,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        t.bestScoreLabel(app.save.bestScore),
                        style: GoogleFonts.manrope(
                          color: colors.text1,
                          fontWeight: FontWeight.w600,
                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 13)),
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
          color: Colors.black45,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.tutorialTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.text0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.tutorialSubtitle,
                style: GoogleFonts.manrope(color: colors.text1),
              ),
              const SizedBox(height: 18),
              Text(
                t.tutorialCta,
                style: GoogleFonts.manrope(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  t.tutorialSkip,
                  style: GoogleFonts.manrope(
                    color: colors.text1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
