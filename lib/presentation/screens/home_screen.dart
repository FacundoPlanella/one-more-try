import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
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
    final d = context.responsive;

    return BannerScaffold(
      background: const Stack(
        children: [
          Positioned.fill(
            child: ScreenBackground(
              'assets/images/backgrounds/fondo_menu_principal.png',
            ),
          ),
          Positioned.fill(child: ColoredBox(color: Color(0x1F000000))),
        ],
      ),
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: d.horizontalMargin * 0.4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // En una ventana ancha y baja (Edge maximizado, landscape) la
              // UI escalada por ancho no entra en alto: el Column reventaba
              // 100+ px. Se achica el bloque entero, sin scroll en Inicio.
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: CoinLabel(
                      amount: save.coins,
                      iconSize: d.scaledSize(18, min: 18),
                      width: d.scaledSize(148, min: 148),
                      style: GoogleFonts.outfit(
                        fontSize: d.scaledFont(16, min: 16),
                        fontWeight: FontWeight.w700,
                        color: woodPlateTextPrimary,
                      ),
                    ),
                  ),
                  AssetIconButton(
                    asset: 'assets/images/ui/boton_config.png',
                    size: d.topButtonSize,
                    tooltip: t.settingsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const BrandLogo(),
              SizedBox(height: d.spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TrophyIcon(size: d.scaledSize(18, min: 18)),
                  const SizedBox(width: 6),
                  Text(
                    t.bestScoreLabel(save.bestScore),
                    style: GoogleFonts.manrope(
                      fontSize: d.scaledFont(16, min: 14),
                      color: colors.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: d.spacing * 0.6),
              RankBadge(
                text: TitleLabel.resolve(context, save.titleId),
                width: d.scaledSize(210, min: 210),
                fontSize: d.scaledFont(15, min: 14),
              ),
              SizedBox(height: d.spacing * 1.2),
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
              SizedBox(height: d.spacing),
              // Cada acceso rápido toma una porción igual de la fila: con la
              // tipografía y el área táctil escaladas en tablet, cuatro
              // etiquetas a tamaño natural sumaban más que el ancho disponible.
              Row(
                children: [
                  Expanded(
                    child: _QuickAccessTile(
                      iconAsset: 'assets/images/ui/icono_skins.png',
                      label: t.linkSkins,
                      iconSize: d.navIconSize,
                      fontSize: d.navFontSize,
                      tapSize: d.navTapSize,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SkinsScreen(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _QuickAccessTile(
                      iconAsset: 'assets/images/ui/icono_tienda.png',
                      label: t.linkShop,
                      iconSize: d.navIconSize,
                      fontSize: d.navFontSize,
                      tapSize: d.navTapSize,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ShopScreen(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _QuickAccessTile(
                      iconAsset: 'assets/images/ui/icono_estadisticas.png',
                      label: t.linkStats,
                      iconSize: d.navIconSize,
                      fontSize: d.navFontSize,
                      tapSize: d.navTapSize,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const StatsScreen(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _QuickAccessTile(
                      iconAsset: 'assets/images/ui/icono_medallas.png',
                      label: t.linkMedals,
                      iconSize: d.navIconSize,
                      fontSize: d.navFontSize,
                      tapSize: d.navTapSize,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MedalsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: d.spacing),
              _DailyRow(
                title: MissionLabels.title(context, mission.id),
                progress: save.dailyProgress,
                target: mission.target,
                done: save.dailyCompleted,
                fontSize: d.scaledFont(14, min: 13),
              ),
              SizedBox(height: d.spacing),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    this.icon,
    this.iconAsset,
    required this.label,
    required this.onTap,
    this.iconSize = 32,
    this.fontSize = 14,
    this.tapSize = 56,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final double tapSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: tapSize, minHeight: tapSize),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: fontSize * 0.4,
            horizontal: fontSize * 0.55,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconAsset != null)
                Image.asset(iconAsset!, width: iconSize, height: iconSize)
              else
                IconBadgeButton(icon: icon!, onPressed: onTap, size: iconSize),
              SizedBox(height: fontSize * 0.3),
              // La etiqueta se achica sola si el idioma la hace más ancha que
              // el reparto de la fila (chino corto, portugués largo): con la
              // tipografía escalando en tablet, cuatro etiquetas a tamaño
              // completo no entraban y la fila desbordaba.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: GoogleFonts.manrope(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: colors.text1,
                  ),
                ),
              ),
            ],
          ),
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
    this.fontSize = 13,
  });

  final String title;
  final int progress;
  final int target;
  final bool done;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    final d = context.responsive;
    final p = (progress / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ui/icono_mision_diaria.png',
              width: fontSize + 6,
              height: fontSize + 6,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                done ? t.dailyComplete : t.dailyLabel(title),
                style: GoogleFonts.manrope(
                  color: colors.text1,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: d.spacing * 0.5),
        _WoodProgressBar(value: p, height: d.scaledSize(28, min: 24)),
      ],
    );
  }
}

/// Barra de progreso a altura lógica. El PNG nativo 2172×724 no define el
/// alto visual: se dibuja con fill dentro de un alto en dp.
class _WoodProgressBar extends StatelessWidget {
  const _WoodProgressBar({required this.value, required this.height});

  final double value;
  final double height;

  static const _channelLeft = 0.115;
  static const _channelTop = 0.44;
  static const _channelBottom = 0.45;
  static const _fillCanvasW = 2103.0;
  static const _fillCanvasH = 748.0;
  static const _fillContentLeft = 166.0;
  static const _fillContentTop = 331.0;
  static const _fillContentW = 1780.0;
  static const _fillContentH = 99.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final channelLeft = w * _channelLeft;
          final channelTop = h * _channelTop;
          final channelHeight = h * (1 - _channelTop - _channelBottom);
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
                  filterQuality: FilterQuality.none,
                ),
              ),
              Positioned(
                left: channelLeft,
                top: channelTop,
                height: channelHeight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
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
                                filterQuality: FilterQuality.none,
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
