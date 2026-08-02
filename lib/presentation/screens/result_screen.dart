import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.coins,
    required this.apply,
  });

  final int score;
  final int coins;
  final ProgressionApplyResult apply;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);

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
                  t.newBest,
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
              if (coins > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: CoinLabel(
                    amount: coins,
                    prefix: '+',
                    iconSize: 18,
                    style: GoogleFonts.manrope(
                      color: colors.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              if (apply.dailyJustCompleted)
                _Chip(text: t.dailyMissionComplete, color: colors.success),
              if (apply.newMedals.isNotEmpty)
                _Chip(
                  text: t.medalUnlocked,
                  color: colors.accent,
                ),
              if (apply.newSkins.isNotEmpty)
                _Chip(
                  text: t.newSkinUnlocked,
                  color: colors.accent,
                  icon: 'assets/images/ui/chest.png',
                ),
              if (apply.newTitle != null)
                _Chip(
                  text: t.titlePrefix(TitleLabel.resolve(context, apply.newTitle!)),
                  color: colors.accent,
                ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: t.playAgain,
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
                label: t.menu,
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
  const _Chip({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.asset(icon!, width: 18, height: 18, filterQuality: FilterQuality.none),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.manrope(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
