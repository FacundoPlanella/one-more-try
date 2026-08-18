import 'package:flutter/material.dart';

/// Recorta un rectángulo fuente del PNG y lo estira al tamaño del padre.
/// Usado por el 3-slice: las tapas conservan proporción; el centro se
/// estira. Las medidas nativas solo sirven para recortar, nunca como
/// tamaño visual.
class AssetSrcRect extends StatelessWidget {
  const AssetSrcRect({
    super.key,
    required this.asset,
    required this.nativeWidth,
    required this.nativeHeight,
    required this.srcLeft,
    required this.srcTop,
    required this.srcWidth,
    required this.srcHeight,
    this.filterQuality = FilterQuality.none,
  });

  final String asset;
  final double nativeWidth;
  final double nativeHeight;
  final double srcLeft;
  final double srcTop;
  final double srcWidth;
  final double srcHeight;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0 || srcWidth <= 0 || srcHeight <= 0) {
          return const SizedBox.shrink();
        }
        final scaleX = w / srcWidth;
        final scaleY = h / srcHeight;
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -srcLeft * scaleX,
                top: -srcTop * scaleY,
                width: nativeWidth * scaleX,
                height: nativeHeight * scaleY,
                child: Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: filterQuality,
                  gaplessPlayback: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 3-slice horizontal: tapas izquierda/derecha a proporción, centro
/// estirable. Sirve para carteles de madera con hojas en los extremos
/// (botones, tarjetas, placas) sin usar el tamaño nativo del PNG como dp.
class HorizontalSliceImage extends StatelessWidget {
  const HorizontalSliceImage({
    super.key,
    required this.asset,
    required this.nativeWidth,
    required this.nativeHeight,
    this.capFraction = 0.22,
    this.filterQuality = FilterQuality.none,
  });

  final String asset;
  final double nativeWidth;
  final double nativeHeight;
  final double capFraction;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final capSrc = nativeWidth * capFraction;
        var capW = capSrc * (h / nativeHeight);
        final maxCap = w * 0.34;
        if (capW > maxCap) capW = maxCap;
        final middle = (w - capW * 2).clamp(0.0, double.infinity);

        Widget strip({
          required double srcLeft,
          required double srcWidth,
          required double destWidth,
        }) {
          return SizedBox(
            width: destWidth,
            height: h,
            child: AssetSrcRect(
              asset: asset,
              nativeWidth: nativeWidth,
              nativeHeight: nativeHeight,
              srcLeft: srcLeft,
              srcTop: 0,
              srcWidth: srcWidth,
              srcHeight: nativeHeight,
              filterQuality: filterQuality,
            ),
          );
        }

        return Row(
          children: [
            strip(srcLeft: 0, srcWidth: capSrc, destWidth: capW),
            if (middle > 0)
              Expanded(
                child: strip(
                  srcLeft: capSrc,
                  srcWidth: nativeWidth - capSrc * 2,
                  destWidth: middle,
                ),
              ),
            strip(
              srcLeft: nativeWidth - capSrc,
              srcWidth: capSrc,
              destWidth: capW,
            ),
          ],
        );
      },
    );
  }
}

/// 9-slice: tapas en los cuatro lados y centro estirable en X e Y. Permite
/// agrandar tarjetas de madera en altura sin deformar esquinas ni bordes
/// decorativos.
class NineSliceImage extends StatelessWidget {
  const NineSliceImage({
    super.key,
    required this.asset,
    required this.nativeWidth,
    required this.nativeHeight,
    this.capFractionH = 0.22,
    this.capFractionV = 0.18,
    this.filterQuality = FilterQuality.none,
  });

  final String asset;
  final double nativeWidth;
  final double nativeHeight;
  final double capFractionH;
  final double capFractionV;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final capSrcW = nativeWidth * capFractionH;
        final capSrcH = nativeHeight * capFractionV;

        var capW = capSrcW * (h / nativeHeight);
        final maxCapW = w * 0.34;
        if (capW > maxCapW) capW = maxCapW;

        var capH = capSrcH * (w / nativeWidth);
        final maxCapH = h * 0.36;
        if (capH > maxCapH) capH = maxCapH;

        final middleW = (w - capW * 2).clamp(0.0, double.infinity);
        final middleH = (h - capH * 2).clamp(0.0, double.infinity);

        Widget cell({
          required double srcLeft,
          required double srcTop,
          required double srcWidth,
          required double srcHeight,
          required double destWidth,
          required double destHeight,
        }) {
          return SizedBox(
            width: destWidth,
            height: destHeight,
            child: AssetSrcRect(
              asset: asset,
              nativeWidth: nativeWidth,
              nativeHeight: nativeHeight,
              srcLeft: srcLeft,
              srcTop: srcTop,
              srcWidth: srcWidth,
              srcHeight: srcHeight,
              filterQuality: filterQuality,
            ),
          );
        }

        Widget rowSlice({
          required double srcTop,
          required double srcHeight,
          required double destHeight,
        }) {
          return Row(
            children: [
              cell(
                srcLeft: 0,
                srcTop: srcTop,
                srcWidth: capSrcW,
                srcHeight: srcHeight,
                destWidth: capW,
                destHeight: destHeight,
              ),
              if (middleW > 0)
                cell(
                  srcLeft: capSrcW,
                  srcTop: srcTop,
                  srcWidth: nativeWidth - capSrcW * 2,
                  srcHeight: srcHeight,
                  destWidth: middleW,
                  destHeight: destHeight,
                ),
              cell(
                srcLeft: nativeWidth - capSrcW,
                srcTop: srcTop,
                srcWidth: capSrcW,
                srcHeight: srcHeight,
                destWidth: capW,
                destHeight: destHeight,
              ),
            ],
          );
        }

        return Column(
          children: [
            rowSlice(srcTop: 0, srcHeight: capSrcH, destHeight: capH),
            if (middleH > 0)
              rowSlice(
                srcTop: capSrcH,
                srcHeight: nativeHeight - capSrcH * 2,
                destHeight: middleH,
              ),
            rowSlice(
              srcTop: nativeHeight - capSrcH,
              srcHeight: capSrcH,
              destHeight: capH,
            ),
          ],
        );
      },
    );
  }
}
