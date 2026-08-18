import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Medidas de un panel ilustrado (los `panel_*.png`): el techo de tamaño y un
/// único factor para escalar su contenido —tipografía, paddings, botones— con
/// el mismo criterio que el arte.
///
/// Cada panel llevaba antes sus medidas fijas en dp, así que en tablet el panel
/// quedaba del mismo tamaño que en un celular y el texto adentro se leía
/// diminuto. Escalar solo la ventana tampoco alcanza: el contenido se
/// desalinearía del marco dibujado en el PNG.
class PanelMetrics {
  const PanelMetrics({
    required this.maxWidth,
    required this.maxHeight,
    required this.scale,
  });

  /// Techos para el `ConstrainedBox` que envuelve al panel. Siguen acotados por
  /// el espacio real disponible: en una pantalla baja manda `constraints`, no el
  /// tamaño de diseño.
  final double maxWidth;
  final double maxHeight;

  /// Multiplicador del contenido interno. Nunca baja de 1 — con las medidas de
  /// diseño el panel ya entraba en un celular angosto, y reducirlas ahí sería
  /// una regresión.
  final double scale;

  static PanelMetrics resolve(
    BuildContext context, {
    required BoxConstraints constraints,
    required double designWidth,
    required double designHeight,
    required double aspectRatio,
    double maxScale = 2.8,
  }) {
    final d = context.responsive;
    final targetWidth = d.scaledSize(designWidth, max: designWidth * maxScale);
    final targetHeight = d.scaledSize(designHeight, max: designHeight * maxScale);
    final maxWidth = constraints.maxWidth.isFinite
        ? math.min(constraints.maxWidth, targetWidth)
        : targetWidth;
    final maxHeight = constraints.maxHeight.isFinite
        ? math.min(constraints.maxHeight, targetHeight)
        : targetHeight;
    // El panel mantiene la proporción del PNG, así que el lado que manda puede
    // ser el alto; el contenido tiene que escalar con el ancho que realmente
    // termina ocupando, no con el techo.
    final width = math.min(maxWidth, maxHeight * aspectRatio);
    return PanelMetrics(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      scale: (width / designWidth).clamp(1.0, maxScale).toDouble(),
    );
  }
}
