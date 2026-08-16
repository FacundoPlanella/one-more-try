import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        leading: WoodBackButton(tooltip: t.back),
        title: TitlePlate(text: t.medalsTitle),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: MedalCatalog.all.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                t.titlePrefix(TitleLabel.resolve(context, save.titleId)),
                style: GoogleFonts.outfit(
                  fontSize: 20,
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
    return AspectRatio(
      aspectRatio: 2172 / 724,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/ui/tarjeta_medalla.png', fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: unlocked ? colors.accent : woodPlateTextSecondary,
                  size: 28,
                ),
                const SizedBox(width: 14),
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
                          fontSize: 15,
                          color: unlocked
                              ? woodPlateTextPrimary
                              : woodPlateTextSecondary,
                        ),
                      ),
                      Text(
                        MedalLabels.description(context, medal.id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: woodPlateTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                  color: unlocked ? colors.success : woodPlateTextSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
