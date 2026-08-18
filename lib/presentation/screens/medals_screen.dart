import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/sliced_image.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/progression_catalogs.dart';
import '../../domain/entities/progression_defs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';

class MedalsScreen extends StatelessWidget {
  const MedalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<AppController>().save;
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);

    return BannerScaffold(
      appBar: GameAppBar(
        title: t.medalsTitle,
        backTooltip: t.back,
        height: context.responsive.appBarHeight,
      ),
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_medallas_titulos.png',
      ),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          12,
          8,
          12,
          context.responsive.listBottomPadding,
        ),
        itemCount: MedalCatalog.all.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                t.titlePrefix(TitleLabel.resolve(context, save.titleId)),
                style: GoogleFonts.outfit(
                  fontSize: context.responsive.scaledFont(20, min: 18),
                  fontWeight: FontWeight.w700,
                  color: colors.accent,
                ),
              ),
            );
          }
          final medal = MedalCatalog.all[index - 1];
          final unlocked = save.medals.contains(medal.id);
          return _MedalCard(medal: medal, unlocked: unlocked);
        },
      ),
    );
  }
}

/// Tarjeta de un logro — tarjeta_medalla.png de fondo (proporción real
/// 2172:724, sin deformar): ícono de medalla a la izquierda, nombre y
/// descripción traducibles al centro, estado (desbloqueada/bloqueada) a la
/// derecha.
class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.medal, required this.unlocked});

  final MedalDef medal;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final d = context.responsive;
    final contentW = ResponsiveDimens.contentWidthOf(context);
    final width = d.isPhone
        ? contentW
        : (contentW * 0.78).clamp(contentW * 0.65, contentW * 0.82).toDouble();
    // Proporción del PNG de la tarjeta: el alto fijo de tablet la estiraba
    // verticalmente y no crecía con la pantalla.
    final height = width / listCardAspectRatio;
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const HorizontalSliceImage(
              asset: 'assets/images/ui/tarjeta_medalla.png',
              nativeWidth: 2172,
              nativeHeight: 724,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: d.scaledSize(24),
                vertical: d.scaledSize(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: unlocked ? colors.accent : woodPlateTextSecondary,
                    size: d.scaledSize(28),
                  ),
                  SizedBox(width: d.scaledSize(14)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MedalLabels.name(context, medal.id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: d.scaledFont(16, min: 15),
                            color: unlocked
                                ? woodPlateTextPrimary
                                : woodPlateTextSecondary,
                          ),
                        ),
                        Text(
                          MedalLabels.description(context, medal.id),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: woodPlateTextSecondary,
                            fontSize: d.scaledFont(13, min: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: d.scaledSize(8)),
                  Icon(
                    unlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    color: unlocked ? colors.success : woodPlateTextSecondary,
                    size: d.scaledSize(22),
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
