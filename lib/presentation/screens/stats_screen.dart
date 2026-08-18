import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
import '../../core/responsive/breakpoints.dart';
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
    final d = context.responsive;
    final minutes = (save.totalPlayTimeSec / 60).toStringAsFixed(1);
    // No hay un acumulador de distancia real (la velocidad de scroll varía
    // con la dificultad de cada partida, y no se guarda por partida) — se
    // deriva solo para mostrar, a partir del tiempo jugado total y la
    // velocidad base del juego. Es una aproximación de UI, no toca
    // SaveData ni ProgressionService.
    final distanceMeters =
        (GameConstants.baseScrollSpeed * save.totalPlayTimeSec / 100).round();

    final stats = <_StatEntry>[
      _StatEntry(
        icon: TrophyIcon(size: d.scaledSize(28)),
        value: '${save.bestScore}',
        label: t.statBestScore,
      ),
      _StatEntry(
        icon: Image.asset(
          'assets/images/ui/icono_partidas_jugadas.png',
          width: d.scaledSize(28),
          height: d.scaledSize(28),
        ),
        value: '${save.totalGames}',
        label: t.statGamesPlayed,
      ),
      _StatEntry(
        icon: Icon(Icons.show_chart_rounded, size: d.scaledSize(26), color: colors.accent),
        value: save.averageScore20.toStringAsFixed(1),
        label: t.statAverage20,
      ),
      _StatEntry(
        icon: Icon(Icons.timer_rounded, size: d.scaledSize(26), color: colors.accent),
        value: t.statMinutes(minutes),
        label: t.statTimePlayed,
      ),
      _StatEntry(
        icon: Image.asset(
          'assets/images/ui/icono_distancia.png',
          width: d.scaledSize(28),
          height: d.scaledSize(28),
        ),
        value: t.statMeters('$distanceMeters'),
        label: t.statDistance,
      ),
      _StatEntry(
        icon: Icon(Icons.auto_awesome_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.totalOrbs}',
        label: t.statOrbsCollected,
      ),
      _StatEntry(
        icon: Icon(Icons.calendar_month_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.daysPlayedCount}',
        label: t.statDaysPlayed,
      ),
      _StatEntry(
        icon: Icon(Icons.trending_up_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.bestBeatenCount}',
        label: t.statRecordsBeaten,
      ),
      _StatEntry(
        icon: Icon(Icons.task_alt_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.dailyMissionsCompleted}',
        label: t.statDailyMissions,
      ),
      _StatEntry(
        icon: Icon(Icons.checkroom_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.unlockedSkins.length}',
        label: t.statSkinsUnlocked,
      ),
      _StatEntry(
        icon: Icon(Icons.workspace_premium_rounded, size: d.scaledSize(26), color: colors.accent),
        value: '${save.medals.length}',
        label: t.statMedals,
      ),
      _StatEntry(
        icon: Icon(Icons.call_split_rounded, size: d.scaledSize(26), color: colors.accent),
        value:
            '${save.deathsPerLane[0]} / ${save.deathsPerLane[1]} / ${save.deathsPerLane[2]}',
        label: t.statDeathsPerLane,
      ),
    ];

    return BannerScaffold(
      appBar: GameAppBar(
        title: t.statsTitle,
        backTooltip: t.back,
        height: context.responsive.appBarHeight,
      ),
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_estadisticas.png',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 300 ? 2 : 1;
          final horizontalPadding = d.scaledSize(16);
          final spacing = d.scaledSize(14);
          // El alto de celda sale del ancho real de la celda y de la proporción
          // del PNG (1125×1052): con un alto fijo, la tarjeta se estiraba
          // verticalmente y en tablet quedaba del mismo tamaño que en celular.
          final cellWidth =
              (constraints.maxWidth -
                  horizontalPadding * 2 -
                  spacing * (columns - 1)) /
              columns;
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              d.scaledSize(12),
              horizontalPadding,
              d.listBottomPadding,
            ),
            itemCount: stats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: cellWidth / _StatCard.aspectRatio,
            ),
            itemBuilder: (context, i) => _StatCard(entry: stats[i]),
          );
        },
      ),
    );
  }
}

class _StatEntry {
  const _StatEntry({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;
}

/// Tarjeta individual de estadística — tarjeta_estadistica.png de fondo
/// (proporción real 1125:1052, sin deformar) con ícono arriba, valor
/// dinámico al centro y descripción traducible abajo.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.entry});

  /// Proporción real de tarjeta_estadistica.png.
  static const double aspectRatio = 1125 / 1052;

  final _StatEntry entry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Todo el contenido se mide contra la tarjeta: así crece igual que el
        // PNG en tablet y nunca desborda el marco de madera.
        final height = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/ui/tarjeta_estadistica.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth * 0.09,
                height * 0.17,
                constraints.maxWidth * 0.09,
                height * 0.19,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: height * 0.19,
                    child: FittedBox(fit: BoxFit.contain, child: entry.icon),
                  ),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          entry.value,
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: height * 0.16,
                            color: woodPlateTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    entry.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: height * 0.085,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                      color: woodPlateTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
