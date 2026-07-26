import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.apply,
  });

  final int score;
  final ProgressionApplyResult apply;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;

    return BannerScaffold(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              if (apply.newBest)
                Text(
                  'NEW BEST',
                  style: GoogleFonts.outfit(
                    color: colors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '$score',
                style: GoogleFonts.outfit(
                  fontSize: 72,
                  fontWeight: FontWeight.w700,
                  color: colors.text0,
                  height: 1,
                ),
              ),
              const SizedBox(height: 18),
              if (apply.dailyJustCompleted)
                _Chip(text: 'Daily mission complete', color: colors.success),
              if (apply.newMedals.isNotEmpty)
                _Chip(
                  text: 'Medal unlocked',
                  color: colors.accent,
                ),
              if (apply.newSkins.isNotEmpty)
                _Chip(
                  text: 'New skin unlocked',
                  color: colors.accent,
                ),
              if (apply.newTitle != null)
                _Chip(
                  text: 'Title: ${TitleLabel.resolve(apply.newTitle!)}',
                  color: colors.accent,
                ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'One more try.',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const GameScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              SubtleLink(
                label: 'Menu',
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeScreen(),
                    ),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
