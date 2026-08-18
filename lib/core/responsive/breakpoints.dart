import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Breakpoints por ANCHO LÓGICO (`MediaQuery.size.width`), nunca por
/// resolución física ni por relación de aspecto.
///
/// Resoluciones de marketing ≠ viewport lógico. Ejemplos típicos:
///
/// | Física       | DPR típico | Ancho lógico | Clase         |
/// |--------------|------------|--------------|---------------|
/// | 720×1280     | 2.0        | 360          | celular       |
/// | 1080×1920    | 2.75–3.0   | 360–392      | celular       |
/// | 1080×2400    | 2.75       | 393          | celular       |
/// | 1600×2560    | 2.0        | 800          | tablet        |
/// | 2048×2732    | 2.0        | 1024         | tablet grande |
///
/// `devicePixelRatio` se respeta porque Flutter ya entrega `size` en dp.
/// No hay que dividir ni multiplicar a mano.
enum DeviceClass { phone, tablet, largeTablet }

class Breakpoints {
  Breakpoints._();

  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  static DeviceClass classify(double logicalWidth) {
    if (logicalWidth < phoneMaxWidth) return DeviceClass.phone;
    if (logicalWidth <= tabletMaxWidth) return DeviceClass.tablet;
    return DeviceClass.largeTablet;
  }
}

/// Medidas reutilizables — un único lugar para ancho de contenido, márgenes,
/// botones, tipografía y escala. Ninguna pantalla debe resolver esto sola.
class ResponsiveDimens {
  const ResponsiveDimens({
    required this.deviceClass,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.devicePixelRatio,
    required this.contentMaxWidth,
    required this.widthFraction,
    required this.horizontalMargin,
    required this.spacing,
    required this.headerHeight,
    required this.buttonHeight,
    required this.cardMaxWidth,
    required this.playableMaxWidth,
    required this.uiScale,
  });

  final DeviceClass deviceClass;
  final double logicalWidth;
  final double logicalHeight;
  final double devicePixelRatio;

  final double contentMaxWidth;
  final double widthFraction;
  final double horizontalMargin;
  final double spacing;
  final double headerHeight;
  final double buttonHeight;
  final double cardMaxWidth;

  /// Ancho máximo del área de carriles (el canvas de Flame sigue a pantalla
  /// completa para que el bosque cubra los laterales).
  final double playableMaxWidth;

  /// Escala de UI derivada del lado corto físico del viewport (referencia
  /// 1080 px), acotada entre 0.80 y 1.45. En celular típico ≈ 1.0; en tablet
  /// grande sube hasta el techo; en pantallas pequeñas baja hasta el piso.
  final double uiScale;

  /// Lado corto lógico del viewport (dp).
  double get shortSide => math.min(logicalWidth, logicalHeight);

  bool get isPhone => deviceClass == DeviceClass.phone;
  bool get isTablet => !isPhone;

  static const double minTouchTarget = 48;
  static const double minTouchTargetTablet = 64;

  static const double playButtonWidthFraction = 0.64;
  static const double playButtonMinHeightPhone = 64;
  static const double playButtonMinFontSize = 18;

  static const double actionButtonWidthFraction = 0.65;

  static const double listCardWidthFraction = 0.78;

  /// Alto del botón principal. En tablet acompaña a [uiScale] en vez de topar
  /// en un valor fijo, que era lo que lo dejaba chico en pantallas grandes.
  double get playButtonHeight => isPhone
      ? playButtonMinHeightPhone
      : scaledSize(playButtonMinHeightPhone, min: 96);

  /// Alto de la barra superior de las pantallas con encabezado
  /// (`GameAppBar`). Base 68 dp: en celular queda igual que antes.
  double get appBarHeight => scaledSize(68);

  double get navTapSize => scaledSize(56);

  double get navIconSize => scaledSize(32);

  double get navFontSize => scaledSize(14);

  /// Monedas y ajustes del encabezado del menú.
  double get topButtonSize => scaledSize(48);

  double get listBottomPadding => scaledSize(24);

  /// Multiplicador del arte del gameplay (jugador, obstáculos, monedas y
  /// poderes). En tablet se usa como piso (x2), no se multiplica otra vez
  /// por la escala del carril. Las colisiones no lo usan.
  double get gameSpriteScale => isPhone ? 1.0 : 2.0;

  /// `base * uiScale`, acotado. Nunca produce un factor < 1 sobre [base]
  /// porque [uiScale] ≥ 1.
  double scaledSize(double base, {double? min, double? max}) {
    var value = base * uiScale;
    if (min != null && value < min) value = min;
    if (max != null && value > max) value = max;
    return value;
  }

  double scaledFont(double base, {double min = 12, double? max}) {
    return scaledSize(base, min: min, max: max);
  }

  /// Ancho efectivo de contenido (el mismo que usa [ResponsiveContent]).
  static double contentWidthOf(BuildContext context) {
    final d = ResponsiveDimens.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final byFraction = screenWidth * d.widthFraction;
    final padded = screenWidth - d.horizontalMargin * 2;
    final limit = d.contentMaxWidth < padded ? d.contentMaxWidth : padded;
    return byFraction < limit ? byFraction : limit;
  }

  /// Resolución de diseño vertical de referencia (1080×1920 px físicos).
  static const double designShortSidePx = 1080;

  /// Ancho lógico de referencia: celular típico en vertical (~1080 px @ 3×).
  static const double phoneReferenceWidth = 360;

  /// Escala UI a partir del lado corto físico. No depende de breakpoints
  /// discretos: cualquier resolución intermedia interpola suavemente.
  static double _uiScaleFor(Size logicalSize, double devicePixelRatio) {
    final physicalShort =
        math.min(logicalSize.width, logicalSize.height) * devicePixelRatio;
    return (physicalShort / designShortSidePx).clamp(0.80, 1.45).toDouble();
  }

  /// Ancho del área de carriles. Es una FRACCIÓN del ancho lógico, no un valor
  /// fijo: el tamaño del personaje, los obstáculos y las monedas se derivan del
  /// ancho de carril, así que un techo fijo (480/540) dejaba los carriles —y con
  /// ellos los sprites— ocupando cada vez menos pantalla a medida que la tablet
  /// crecía. Con fracción, la proporción personaje/pantalla de un celular se
  /// mantiene; los topes solo evitan carriles absurdos.
  static double _playableWidthFor(DeviceClass deviceClass, double width) {
    switch (deviceClass) {
      case DeviceClass.phone:
        return double.infinity;
      case DeviceClass.tablet:
        return (width * 0.80).clamp(520.0, 760.0);
      case DeviceClass.largeTablet:
        return (width * 0.76).clamp(680.0, 1000.0);
    }
  }

  static ResponsiveDimens of(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final deviceClass = Breakpoints.classify(size.width);
    final uiScale = _uiScaleFor(size, mq.devicePixelRatio);
    // Todas las medidas de layout derivan de [uiScale] sobre la base de
    // celular calibrada a 1080×1920.
    final widthFraction = switch (deviceClass) {
      DeviceClass.phone => 0.92,
      DeviceClass.tablet => 0.90,
      DeviceClass.largeTablet => 0.86,
    };
    final maxContent = switch (deviceClass) {
      DeviceClass.phone => double.infinity,
      DeviceClass.tablet => 880.0 * uiScale,
      DeviceClass.largeTablet => 980.0 * uiScale,
    };
    return ResponsiveDimens(
      deviceClass: deviceClass,
      logicalWidth: size.width,
      logicalHeight: size.height,
      devicePixelRatio: mq.devicePixelRatio,
      contentMaxWidth: maxContent,
      widthFraction: widthFraction,
      horizontalMargin: 16 * uiScale,
      spacing: 12 * uiScale,
      headerHeight: 56 * uiScale,
      buttonHeight: 56 * uiScale,
      cardMaxWidth: double.infinity,
      playableMaxWidth: _playableWidthFor(deviceClass, size.width),
      uiScale: uiScale,
    );
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveDimens get responsive => ResponsiveDimens.of(this);
}

/// Medidas compartidas para tarjetas de lista (Skins, Tienda, Medallas).
class CatalogListCardMetrics {
  CatalogListCardMetrics._();

  /// Proporción nativa de `tarjeta_skin_tienda.png` / `tarjeta_medalla.png`.
  static const double frameAspectRatio = 2172 / 724;

  /// Ancho efectivo: ocupa el ancho de contenido responsive sin encogerse
  /// extra en tablet (evita la franja central angosta).
  static double widthOf(BuildContext context) {
    return ResponsiveDimens.contentWidthOf(context);
  }

  /// Alto de tarjeta: proporción exacta del PNG — el marco y el contenido
  /// comparten la misma caja.
  static double heightOf(BuildContext context, double width) {
    return width / frameAspectRatio;
  }

  /// Sprite: 200 % del tamaño base, sin superar el alto interior de la tarjeta.
  static const double _previewBaseFraction = 0.78;
  static const double previewSizeMultiplier = 2.0;

  static double previewSize(double cardHeight, EdgeInsets padding) {
    final innerH = cardHeight - padding.vertical;
    return math.min(
      innerH * _previewBaseFraction * previewSizeMultiplier,
      innerH * 0.96,
    );
  }

  /// Ancho del botón Comprar/Equipar: cabe en el espacio restante y no
  /// supera el alto interior (proporción ~3.2:1 del PNG).
  static double purchaseButtonWidth(
    double cardWidth,
    double cardHeight,
    EdgeInsets padding,
    double preview,
  ) {
    final innerW = cardWidth - padding.horizontal;
    final innerH = cardHeight - padding.vertical;
    final gaps = cardWidth * 0.04;
    final minText = innerW * 0.30;
    final available = innerW - preview - gaps - minText;
    final maxByHeight = innerH * 3.15;
    return available.clamp(56.0, math.min(maxByHeight, cardWidth * 0.19));
  }

  /// Alias para columna de acción (candado / check / botón).
  static double actionColumnWidth(
    BuildContext context,
    double cardWidth,
    double cardHeight,
  ) {
    final padding = contentPadding(cardHeight);
    final preview = previewSize(cardHeight, padding);
    return purchaseButtonWidth(cardWidth, cardHeight, padding, preview);
  }

  /// Padding interno proporcional al alto de la tarjeta.
  static EdgeInsets contentPadding(double cardHeight) {
    return EdgeInsets.symmetric(
      horizontal: cardHeight * 0.055,
      vertical: cardHeight * 0.09,
    );
  }

  /// Separación vertical entre tarjetas en listas.
  static double listSeparator(BuildContext context) {
    return context.responsive.scaledSize(12);
  }

  /// Padding horizontal de la lista (simétrico).
  static EdgeInsets listPadding(BuildContext context) {
    final d = context.responsive;
    return EdgeInsets.fromLTRB(0, d.scaledSize(8), 0, d.listBottomPadding);
  }
}

/// Acota el CONTENIDO (nunca el fondo). Sin Transform global.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveDimens.contentWidthOf(context);
    return Center(
      child: SizedBox(width: width, child: child),
    );
  }
}
