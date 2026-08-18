import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ads_service.dart';
import 'breakpoints.dart';

/// Cascarón de pantalla reutilizable. Separa:
/// 1. Fondo full-screen (cover, detrás de todo, sin maxWidth).
/// 2. Safe area de contenido (una sola vez).
/// 3. Encabezado fijo.
/// 4. Contenido responsive (ancho máximo, centrado).
/// 5. Scroll, cuando el caller lo pide o trae su propio scroll.
/// 6. Publicidad (solo si el banner está visible).
/// 7. Inset inferior del sistema (gestos / barra de navegación).
///
/// El fondo nunca entra al scroll ni a [ResponsiveContent].
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.body,
    this.background,
    this.header,
    this.constrainWidth = true,
    this.scroll = false,
    this.safeTop = true,
    this.showBanner = true,
    this.bodyPadding,
  });

  final Widget body;

  /// Capa de fondo a pantalla completa. Debe usar `BoxFit.cover` y no
  /// llevar `maxWidth`. Vive detrás del Scaffold, así cubre header y ads.
  final Widget? background;

  final PreferredSizeWidget? header;

  /// Acota el contenido (no el fondo) al ancho de [ResponsiveContent].
  final bool constrainWidth;

  /// Envuelve [body] en un [SingleChildScrollView]. Las pantallas con
  /// ListView/GridView propio deben dejarlo en false.
  final bool scroll;

  /// Safe area superior. Las pantallas que ya la aplican al HUD (juego)
  /// deben pasar false para no duplicarla.
  final bool safeTop;

  /// Muestra la franja del banner solo cuando hay un anuncio cargado.
  final bool showBanner;

  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    final ads = showBanner ? context.watch<AdsService>() : null;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    Widget content = body;
    if (bodyPadding != null) {
      content = Padding(padding: bodyPadding!, child: content);
    }
    if (constrainWidth) {
      content = ResponsiveContent(child: content);
    }
    if (scroll) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      );
    }

    final scaffold = Scaffold(
      backgroundColor: background == null ? null : Colors.transparent,
      appBar: header,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: safeTop,
              bottom: false,
              child: content,
            ),
          ),
          SafeArea(
            top: false,
            left: false,
            right: false,
            child: ads != null
                ? ads.bannerWidget(active: isCurrent)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    if (background == null) return scaffold;
    return Stack(
      children: [
        Positioned.fill(child: background!),
        scaffold,
      ],
    );
  }
}
