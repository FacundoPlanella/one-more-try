import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<AppController>().save;
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    final minutes = (save.totalPlayTimeSec / 60).toStringAsFixed(1);

    final rows = <(String, String)>[
      (t.statBestScore, '${save.bestScore}'),
      (t.statGamesPlayed, '${save.totalGames}'),
      (t.statAverage20, save.averageScore20.toStringAsFixed(1)),
      (t.statTimePlayed, t.statMinutes(minutes)),
      (t.statOrbsCollected, '${save.totalOrbs}'),
      (t.statDaysPlayed, '${save.daysPlayedCount}'),
      (t.statRecordsBeaten, '${save.bestBeatenCount}'),
      (t.statDailyMissions, '${save.dailyMissionsCompleted}'),
      (t.statSkinsUnlocked, '${save.unlockedSkins.length}'),
      (t.statMedals, '${save.medals.length}'),
      (
        t.statDeathsPerLane,
        '${save.deathsPerLane[0]} / ${save.deathsPerLane[1]} / ${save.deathsPerLane[2]}',
      ),
    ];

    return BannerScaffold(
      appBar: AppBar(title: Text(t.statsTitle)),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: rows.length,
        separatorBuilder: (_, _) => Divider(color: colors.lane),
        itemBuilder: (context, i) {
          final row = rows[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.$1,
                    style: GoogleFonts.manrope(color: colors.text1),
                  ),
                ),
                Text(
                  row.$2,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
