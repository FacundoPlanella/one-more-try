import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';
import 'medals_screen.dart';
import 'settings_screen.dart';
import 'skins_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;
    final mission = ProgressionService.currentMission(save);

    return BannerScaffold(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  icon: Icon(Icons.tune_rounded, color: colors.text1),
                ),
              ),
              const Spacer(flex: 2),
              const BrandTitle(),
              const SizedBox(height: 10),
              Text(
                'Best  ${save.bestScore}',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  color: colors.text1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                TitleLabel.resolve(save.titleId),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Play',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GameScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SubtleLink(
                    label: 'Skins',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SkinsScreen(),
                      ),
                    ),
                  ),
                  SubtleLink(
                    label: 'Stats',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StatsScreen(),
                      ),
                    ),
                  ),
                  SubtleLink(
                    label: 'Medals',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MedalsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _DailyRow(
                title: mission.title,
                progress: save.dailyProgress,
                target: mission.target,
                done: save.dailyCompleted,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleLabel {
  static String resolve(String id) {
    switch (id) {
      case 'aprendiz':
        return 'Apprentice';
      case 'constante':
        return 'Steady';
      case 'cazador':
        return 'Record hunter';
      case 'minimalista':
        return 'Minimalist';
      case 'uno_mas':
        return 'One more';
      case 'equilibrio':
        return 'Balance';
      case 'one_more_try':
        return 'One more try.';
      default:
        return 'Novice';
    }
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.title,
    required this.progress,
    required this.target,
    required this.done,
  });

  final String title;
  final int progress;
  final int target;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final p = (progress / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          done ? 'Daily complete' : 'Daily: $title',
          style: GoogleFonts.manrope(
            color: colors.text1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: p,
            minHeight: 6,
            backgroundColor: colors.lane,
            color: done ? colors.success : colors.accent,
          ),
        ),
      ],
    );
  }
}
