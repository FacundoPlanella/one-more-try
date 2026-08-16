import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';
import 'medals_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
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
    final t = AppLocalizations.of(context);

    return BannerScaffold(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CoinLabel(
                    amount: save.coins,
                    iconSize: 18,
                    width: 148,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: woodPlateTextPrimary,
                    ),
                  ),
                  AssetIconButton(
                    asset: 'assets/images/ui/boton_config.png',
                    tooltip: t.settingsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              const BrandTitle(),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TrophyIcon(size: 18),
                  const SizedBox(width: 6),
                  Text(
                    t.bestScoreLabel(save.bestScore),
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: colors.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RankBadge(text: TitleLabel.resolve(context, save.titleId)),
              const Spacer(flex: 2),
              PrimaryButton(
                label: t.play,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAccessTile(
                    iconAsset: 'assets/images/ui/icono_skins.png',
                    label: t.linkSkins,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SkinsScreen(),
                      ),
                    ),
                  ),
                  _QuickAccessTile(
                    iconAsset: 'assets/images/ui/icono_tienda.png',
                    label: t.linkShop,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShopScreen(),
                      ),
                    ),
                  ),
                  _QuickAccessTile(
                    iconAsset: 'assets/images/ui/icono_estadisticas.png',
                    label: t.linkStats,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StatsScreen(),
                      ),
                    ),
                  ),
                  _QuickAccessTile(
                    iconAsset: 'assets/images/ui/icono_medallas.png',
                    label: t.linkMedals,
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
                title: MissionLabels.title(context, mission.id),
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

/// Acceso rápido del Home (Skins/Shop/Stats/Medals): ícono + etiqueta, con
/// toda la columna como única zona pulsable (no solo el ícono). [iconAsset]
/// dibuja el PNG propio del rubro (proporción/tamaño intactos); si no hay
/// asset todavía, cae al ícono de Material genérico con chapa de madera.
class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    this.icon,
    this.iconAsset,
    required this.label,
    required this.onTap,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAsset != null)
              Image.asset(iconAsset!, width: 52, height: 52)
            else
              IconBadgeButton(icon: icon!, onPressed: onTap, size: 52),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.text1,
              ),
            ),
          ],
        ),
      ),
    );
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
    final t = AppLocalizations.of(context);
    final p = (progress / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ui/icono_mision_diaria.png',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                done ? t.dailyComplete : t.dailyLabel(title),
                style: GoogleFonts.manrope(
                  color: colors.text1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _WoodProgressBar(value: p, done: done),
      ],
    );
  }
}

/// Barra de progreso de la misión diaria — barra_progreso_base.png como
/// marco fijo (proporción original, sin deformar); el relleno dinámico se
/// dibuja arriba, acotado al canal oscuro medido en el PNG (fracciones del
/// canvas 2172×724) para no pisar nunca el borde dorado. El ancho sigue al
/// espacio disponible vía [AspectRatio], así que se adapta solo a
/// cualquier resolución.
class _WoodProgressBar extends StatelessWidget {
  const _WoodProgressBar({required this.value, required this.done});

  final double value;
  final bool done;

  static const _channelLeft = 0.115;
  static const _channelTop = 0.44;
  static const _channelBottom = 0.45;

  // Medidas nativas de barra_progreso_relleno.png (canvas 2103×748): bbox
  // del contenido opaco (la píldora verde), para escalarlo por altura sin
  // deformarlo y recortar el padding transparente que trae el PNG.
  static const _fillCanvasW = 2103.0;
  static const _fillCanvasH = 748.0;
  static const _fillContentLeft = 166.0;
  static const _fillContentTop = 331.0;
  static const _fillContentW = 1780.0;
  static const _fillContentH = 99.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2172 / 724,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final channelLeft = w * _channelLeft;
          final channelTop = h * _channelTop;
          final channelHeight = h * (1 - _channelTop - _channelBottom);

          // Escala uniforme (misma en X e Y): la altura del contenido del
          // relleno pasa a medir justo channelHeight, sin deformarlo. Con
          // la proporción real del asset esto ya da un ancho natural menor
          // al canal completo, así que nunca lo supera.
          final scale = channelHeight / _fillContentH;
          final contentWidth = _fillContentW * scale;
          final fullImgWidth = _fillCanvasW * scale;
          final fullImgHeight = _fillCanvasH * scale;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/ui/barra_progreso_base.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: channelLeft,
                top: channelTop,
                height: channelHeight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    // Recorte nativo: revela de izquierda a derecha según
                    // el % actual, nunca más que el ancho natural del
                    // relleno (que ya entra en el canal por diseño).
                    widthFactor: value.clamp(0.0, 1.0),
                    child: SizedBox(
                      width: contentWidth,
                      height: channelHeight,
                      child: ClipRect(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -_fillContentLeft * scale,
                              top: -_fillContentTop * scale,
                              width: fullImgWidth,
                              height: fullImgHeight,
                              child: Image.asset(
                                'assets/images/ui/barra_progreso_relleno.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
