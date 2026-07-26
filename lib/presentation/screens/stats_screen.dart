import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<AppController>().save;
    final colors = context.oneColors;
    final minutes = (save.totalPlayTimeSec / 60).toStringAsFixed(1);

    final rows = <(String, String)>[
      ('Best score', '${save.bestScore}'),
      ('Games played', '${save.totalGames}'),
      ('Average (last 20)', save.averageScore20.toStringAsFixed(1)),
      ('Time played', '$minutes min'),
      ('Orbs collected', '${save.totalOrbs}'),
      ('Days played', '${save.daysPlayedCount}'),
      ('Records beaten', '${save.bestBeatenCount}'),
      ('Daily missions', '${save.dailyMissionsCompleted}'),
      ('Skins unlocked', '${save.unlockedSkins.length}'),
      ('Medals', '${save.medals.length}'),
      (
        'Deaths L / C / R',
        '${save.deathsPerLane[0]} / ${save.deathsPerLane[1]} / ${save.deathsPerLane[2]}',
      ),
    ];

    return BannerScaffold(
      appBar: AppBar(title: const Text('Stats')),
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
