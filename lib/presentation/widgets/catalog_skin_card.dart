import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/sliced_image.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/skin.dart';
import 'common_widgets.dart';

/// Tarjeta ilustrada compartida entre Skins y Tienda (`tarjeta_skin_tienda.png`).
///
/// El marco usa [HorizontalSliceImage] con la proporción nativa del PNG — nunca
/// se fuerza un alto mayor al aspect ratio, porque el 9-slice vertical dejaba
/// la cara de madera abajo y el texto flotando arriba.
class CatalogSkinCard extends StatelessWidget {
  const CatalogSkinCard({
    super.key,
    required this.skin,
    required this.statusLine,
    this.secondaryLine,
    this.statusWidget,
    required this.action,
    this.equipped = false,
    this.onTap,
  });

  final SkinDef skin;
  final String statusLine;
  final String? secondaryLine;
  final Widget? statusWidget;
  final Widget action;
  final bool equipped;
  final VoidCallback? onTap;

  static const _frameAsset = 'assets/images/ui/tarjeta_skin_tienda.png';
  static const _nativeW = 2172.0;
  static const _nativeH = 724.0;

  @override
  Widget build(BuildContext context) {
    final d = context.responsive;
    final colors = context.oneColors;
    final width = CatalogListCardMetrics.widthOf(context);
    final height = CatalogListCardMetrics.heightOf(context, width);
    final padding = CatalogListCardMetrics.contentPadding(height);
    final preview = CatalogListCardMetrics.previewSize(height, padding);
    final actionW = CatalogListCardMetrics.purchaseButtonWidth(
      width,
      height,
      padding,
      preview,
    );
    final innerH = height - padding.vertical;

    final nameStyle = GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: d.scaledFont(16, min: 13).clamp(13, height * 0.17),
      color: woodPlateTextPrimary,
      height: 1.1,
    );
    final secondaryStyle = GoogleFonts.manrope(
      color: woodPlateTextSecondary,
      fontSize: d.scaledFont(12, min: 11).clamp(11, height * 0.13),
      height: 1.1,
    );
    final statusStyle = GoogleFonts.manrope(
      color: woodPlateTextSecondary,
      fontSize: d.scaledFont(12, min: 11).clamp(11, height * 0.13),
      height: 1.15,
    );

    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: equipped
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.14),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.55),
                      blurRadius: height * 0.1,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : null,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(height * 0.14),
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height * 0.14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const HorizontalSliceImage(
                      asset: _frameAsset,
                      nativeWidth: _nativeW,
                      nativeHeight: _nativeH,
                    ),
                    Padding(
                      padding: padding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: preview,
                            child: Center(
                              child: SkinPreview(skin: skin, size: preview),
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    RarityDiamond(
                                      color: skin.color,
                                      size: height * 0.16,
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Expanded(
                                      child: Text(
                                        skin.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: nameStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                if (secondaryLine != null) ...[
                                  SizedBox(height: height * 0.025),
                                  Text(
                                    secondaryLine!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: secondaryStyle,
                                  ),
                                ],
                                SizedBox(height: height * 0.04),
                                statusWidget ??
                                    Text(
                                      statusLine,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: statusStyle,
                                    ),
                              ],
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          SizedBox(
                            width: actionW,
                            height: innerH,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: action,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de skin equipada — proporcional al alto de la tarjeta.
class CatalogSkinEquippedBadge extends StatelessWidget {
  const CatalogSkinEquippedBadge({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final width = CatalogListCardMetrics.widthOf(context);
    final height = CatalogListCardMetrics.heightOf(context, width);
    final size = (height * 0.44).clamp(40.0, 72.0);
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        'assets/images/ui/indicador_skin_equipada.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}

/// Candado de skin bloqueada — proporcional al alto de la tarjeta.
class CatalogSkinLockedBadge extends StatelessWidget {
  const CatalogSkinLockedBadge({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final width = CatalogListCardMetrics.widthOf(context);
    final height = CatalogListCardMetrics.heightOf(context, width);
    final size = (height * 0.40).clamp(36.0, 64.0);
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        'assets/images/ui/indicador_skin_bloqueada.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}
