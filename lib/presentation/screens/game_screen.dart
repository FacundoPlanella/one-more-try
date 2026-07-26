import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../../game/one_game.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;
  bool _ended = false;
  late OneGame _game;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    final colors = _resolveColors(app);
    _game = OneGame(
      skinId: app.save.equippedSkin,
      bgColor: colors.bg,
      laneColor: colors.lane,
      obstacleColor: colors.obstacle,
      accentColor: colors.accent,
      reduceMotion: app.save.reduceMotion,
      onScore: (s) {
        if (mounted) setState(() => _score = s);
      },
      onOrb: () {
        app.audio.playOrb();
        app.haptics.light();
      },
      onTapLane: () {
        app.audio.playTap();
        app.haptics.light();
      },
      onDeath: (score, duration, orbs, lane) {
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
            deathLane: lane,
            collectedAnyOrb: collected,
          ),
        );
        if (result.newBest) app.audio.playBest();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (_, _, _) => ResultScreen(
              score: score,
              apply: result,
            ),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
    );
    if (!app.save.tutorialDone) {
      _game.paused = true;
    }
  }

  _GameColors _resolveColors(AppController app) {
    // Usa tema oscuro de juego estable (mejor contraste en motion).
    final isLight = app.save.themeMode == 'light';
    if (isLight) {
      return const _GameColors(
        bg: Color(0xFFF3F5F7),
        lane: Color(0xFFD7DEE5),
        obstacle: Color(0xFF64748B),
        accent: Color(0xFF0F766E),
      );
    }
    return const _GameColors(
      bg: Color(0xFF0B0D10),
      lane: Color(0xFF1F2933),
      obstacle: Color(0xFF2A3441),
      accent: Color(0xFF5EEAD4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;

    return BannerScaffold(
      child: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: colors.text1),
                  ),
                  Expanded(
                    child: Text(
                      '$_score',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: colors.text0,
                      ),
                    ),
                  ),
                  Text(
                    'Best ${app.save.bestScore}',
                    style: GoogleFonts.manrope(
                      color: colors.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!app.save.tutorialDone)
            _TutorialOverlay(
              onDone: () {
                app.completeTutorial();
                _game.paused = false;
              },
            ),
        ],
      ),
    );
  }
}

class _GameColors {
  const _GameColors({
    required this.bg,
    required this.lane,
    required this.obstacle,
    required this.accent,
  });

  final Color bg;
  final Color lane;
  final Color obstacle;
  final Color accent;
}

class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDone,
        child: Container(
          color: Colors.black45,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tap to change lane',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.text0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Avoid blocks. One more try.',
                style: GoogleFonts.manrope(color: colors.text1),
              ),
              const SizedBox(height: 18),
              Text(
                'Tap anywhere to start',
                style: GoogleFonts.manrope(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
