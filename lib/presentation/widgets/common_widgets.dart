import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/skin.dart';
import '../../services/ads_service.dart';

/// Envuelve el contenido y reserva siempre el espacio del banner.
class BannerScaffold extends StatelessWidget {
  const BannerScaffold({
    super.key,
    required this.child,
    this.appBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdsService>();
    // Solo la ruta visible monta el AdWidget (Home debajo de Game no lo duplica).
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(child: child),
          SafeArea(
            top: false,
            child: ads.bannerWidget(active: isCurrent),
          ),
        ],
      ),
    );
  }
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return Text(
      GameConstants.appName,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: compact ? 28 : 44,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: colors.text0,
        letterSpacing: -0.5,
        shadows: [
          const Shadow(
            color: Color(0x731B0F06),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
          Shadow(
            color: colors.accent.withValues(alpha: 0.28),
            blurRadius: 18,
          ),
        ],
      ),
    );
  }
}

/// Texto legible sobre el cartel de madera — crema en botón activo, tostado
/// apagado cuando `boton_deshabilitado` está en juego. No usa colors.text0
/// porque el arte del cartel no cambia entre tema claro/oscuro.
const Color _signTextEnabled = Color(0xFFFBE8C8);
const Color _signTextDisabled = Color(0xFFC9BBA4);

/// Mismos tonos fijos que [_signTextEnabled]/[_signTextDisabled], públicos
/// para pantallas que dibujan texto directamente sobre otro artwork de
/// madera (ej. `tarjeta_skin_tienda.png`) — el fondo no cambia con el tema,
/// así que el texto tampoco puede depender de `colors.text0`.
const Color woodPlateTextPrimary = _signTextEnabled;
const Color woodPlateTextSecondary = Color(0xFFD9C6A8);
const List<Shadow> _signTextShadow = [
  Shadow(color: Color(0xCC1B0F06), offset: Offset(0, 2), blurRadius: 3),
];

/// Botón con forma de cartel de madera (boton_normal/presionado/
/// deshabilitado.png) — 3 estados reales, feedback táctil (escala + swap de
/// imagen) para que se sienta cómodo en pantalla táctil.
class _SignButton extends StatefulWidget {
  const _SignButton({
    required this.label,
    required this.onPressed,
    required this.expanded,
    required this.fontSize,
    this.maxWidth,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final double fontSize;
  final double? maxWidth;

  @override
  State<_SignButton> createState() => _SignButtonState();
}

class _SignButtonState extends State<_SignButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final asset = !enabled
        ? 'assets/images/ui/boton_deshabilitado.png'
        : _pressed
            ? 'assets/images/ui/boton_presionado.png'
            : 'assets/images/ui/boton_normal.png';

    final sign = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: AspectRatio(
        aspectRatio: 1774 / 887,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: enabled ? _signTextEnabled : _signTextDisabled,
                  shadows: _signTextShadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onPressed,
        child: sign,
      ),
    );

    if (widget.expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    if (widget.maxWidth != null) {
      return SizedBox(width: widget.maxWidth, child: button);
    }
    return button;
  }
}

/// CTA principal — cartel de madera grande. Misma firma pública de siempre,
/// así que ningún call site (Home, Result) necesita cambios.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return _SignButton(
      label: label,
      onPressed: onPressed,
      expanded: expanded,
      fontSize: 21,
    );
  }
}

/// Cartel de madera compacto — para acciones secundarias en listas (Buy,
/// Equip, comprar perk). El estado deshabilitado cubre "no alcanza el saldo".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 126,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _SignButton(
      label: label,
      onPressed: onPressed,
      expanded: false,
      fontSize: 14,
      maxWidth: width,
    );
  }
}

/// Botón de compra — boton_comprar.png en reposo/presionado (con escala al
/// tocar) y boton_comprar_deshabilitado.png cuando `onPressed` es null (sin
/// saldo o skin bloqueada). El swap es automático según `onPressed`, así
/// que el caller solo pasa `null` para deshabilitar — misma pauta que
/// PrimaryButton/SecondaryButton.
class PurchaseButton extends StatefulWidget {
  const PurchaseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 116,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;

  @override
  State<PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final asset = enabled
        ? 'assets/images/ui/boton_comprar.png'
        : 'assets/images/ui/boton_comprar_deshabilitado.png';
    final sign = AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: AspectRatio(
        // Proporción original de boton_comprar*.png — no se deforma.
        aspectRatio: 1855 / 848,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: enabled ? woodPlateTextPrimary : _signTextDisabled,
                  shadows: _signTextShadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: widget.width,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onPressed,
          child: sign,
        ),
      ),
    );
  }
}

/// Placa de título (placa_titulo.png) para encabezados de pantallas
/// secundarias (Tienda, Créditos, Estadísticas, Skins, Medallas). Altura
/// fija — el ancho se adapta al largo del texto (para que una traducción
/// más extensa no se corte) recortando primero el margen transparente del
/// PNG y estirando ese grabado limpio al tamaño exacto que hace falta, sin
/// dejar nunca hueco vacío ni desbordar el espacio disponible del AppBar.
class TitlePlate extends StatelessWidget {
  const TitlePlate({
    super.key,
    required this.text,
    this.height = 40,
    this.fontSize = 17,
  });

  final String text;
  final double height;
  final double fontSize;

  // Medidas nativas de placa_titulo.png (canvas 2032×774): bbox del grabado
  // opaco, para recortar el margen transparente que trae el PNG.
  static const _canvasW = 2032.0;
  static const _canvasH = 774.0;
  static const _contentLeft = 224.0;
  static const _contentTop = 168.0;
  static const _contentW = 1584.0;
  static const _contentH = 432.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: woodPlateTextPrimary,
      shadows: _signTextShadow,
    );
    // El TextPainter tiene que medir con el mismo textScaler que después
    // usa el Text real (accesibilidad → letra más grande en el sistema);
    // si no, esto mide de menos y el título termina truncado en "…".
    final painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    const horizontalPadding = 34.0;
    final minWidth = height * (_contentW / _contentH) * 0.6;
    final wanted = painter.width + horizontalPadding * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        var width = wanted < minWidth ? minWidth : wanted;
        if (constraints.maxWidth.isFinite && width > constraints.maxWidth) {
          width = constraints.maxWidth;
        }
        final scaleX = width / _contentW;
        final scaleY = height / _contentH;
        final fullImgWidth = _canvasW * scaleX;
        final fullImgHeight = _canvasH * scaleY;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -_contentLeft * scaleX,
                      top: -_contentTop * scaleY,
                      width: fullImgWidth,
                      height: fullImgHeight,
                      child: Image.asset(
                        'assets/images/ui/placa_titulo.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                // Además de medir bien arriba, esto es una red de
                // seguridad: si el texto igual no entra (fuente aún no
                // cargada, etc.), encoge en vez de truncar con "…".
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: textStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Insignia de rango (insignia_rango.png) del Home — hoja + cartel +
/// cintas colgantes. Tamaño fijo y proporción intacta (no se estira como
/// [TitlePlate]: la silueta de cinta/hoja se vería rota si se deformara),
/// el nombre del rango se ajusta con [FittedBox] para caber en cualquier
/// idioma sin desbordar ni tocar las puntas del cartel.
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.text, this.width = 210});

  final String text;
  final double width;

  static const _aspect = 1814 / 867;
  // Franja de madera dentro del PNG (fracciones del canvas completo):
  // arriba de esa franja está la hoja, abajo las cintas colgantes.
  static const _verticalBias = -0.096;
  static const _horizontalInset = 0.20;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / _aspect,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/insignia_rango.png',
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: const Alignment(0, _verticalBias),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * _horizontalInset,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: woodPlateTextPrimary,
                    shadows: _signTextShadow,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recorta un rectángulo horizontal nativo de [asset] (franja completa de
/// ancho, alto [srcHeight] arrancando en [srcTop]) y lo estira —X e Y por
/// separado— para llenar exactamente el tamaño que le da el padre. Usado
/// para armar el 3-slice vertical de [ContentCard] (tapa/cuerpo/tapa) sin
/// deformar las esquinas decoradas.
class _ImageStrip extends StatelessWidget {
  const _ImageStrip({
    required this.asset,
    required this.nativeW,
    required this.nativeH,
    required this.srcTop,
    required this.srcHeight,
  });

  final String asset;
  final double nativeW;
  final double nativeH;
  final double srcTop;
  final double srcHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final scaleX = w / nativeW;
        final scaleY = h / srcHeight;
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: -srcTop * scaleY,
                width: nativeW * scaleX,
                height: nativeH * scaleY,
                child: Image.asset(asset, fit: BoxFit.fill),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta de contenido (tarjeta_contenido.png) — fondo reusable para
/// bloques de información de largo variable (Créditos, Estadísticas,
/// Medallas). A diferencia de las placas de tamaño fijo, esta se arma como
/// 3-slice vertical (tapa dorada+hoja arriba, madera lisa estirable en el
/// medio, tapa dorada+hoja abajo) para poder crecer con el contenido sin
/// estirar ni las esquinas decoradas ni el borde. El ancho de las tapas
/// escala junto con el ancho disponible, así que el grosor del marco se ve
/// consistente en cualquier resolución. El contenido interno puede exceder
/// el alto y scrollear: la tarjeta no impone su propio scroll, hereda el
/// del contenedor (ListView/SingleChildScrollView) donde se la use.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const _asset = 'assets/images/ui/tarjeta_contenido.png';
  static const _nativeW = 1096.0;
  static const _nativeH = 1435.0;
  static const _capH = 170.0;
  static const _middleH = _nativeH - _capH * 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho fijo y explícito para todo el árbol de abajo: sin esto, el
        // Stack se dimensiona según el contenido de primer plano (un
        // Column de texto sin ancho propio), y un título largo terminaba
        // empujando el texto más allá del borde de la tarjeta en vez de
        // ajustarse/wrappear dentro de ella.
        final w = constraints.maxWidth;
        final capH = _capH * (w / _nativeW);
        return SizedBox(
          width: w,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(
                      height: capH,
                      width: double.infinity,
                      child: _ImageStrip(
                        asset: _asset,
                        nativeW: _nativeW,
                        nativeH: _nativeH,
                        srcTop: 0,
                        srcHeight: _capH,
                      ),
                    ),
                    Expanded(
                      child: _ImageStrip(
                        asset: _asset,
                        nativeW: _nativeW,
                        nativeH: _nativeH,
                        srcTop: _capH,
                        srcHeight: _middleH,
                      ),
                    ),
                    SizedBox(
                      height: capH,
                      width: double.infinity,
                      child: _ImageStrip(
                        asset: _asset,
                        nativeW: _nativeW,
                        nativeH: _nativeH,
                        srcTop: _capH + _middleH,
                        srcHeight: _capH,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: padding,
                child: SizedBox(width: double.infinity, child: child),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Separador decorativo (separador_seccion.png) entre bloques de
/// contenido. Puramente visual — [IgnorePointer] asegura que nunca capture
/// toques ni interfiera con el scroll del contenedor. Ancho completo del
/// contenedor, alto uniforme; el ornamento central queda siempre
/// horizontalmente centrado porque el estiramiento es lineal.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key, this.height = 18});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(
          'assets/images/ui/separador_seccion.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

/// Panel de madera reusable — reemplaza los `Container` con borde plano que
/// se repetían en las listas de Tienda/Skins/Medallas.
class WoodPanel extends StatelessWidget {
  const WoodPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
    this.borderRadius = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.bg1, Color.lerp(colors.bg1, Colors.black, 0.32)!],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: highlighted
              ? colors.accent
              : colors.accent.withValues(alpha: 0.32),
          width: highlighted ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Ícono con chapa circular de madera — usado para acciones chicas (ajustes,
/// cerrar el juego, accesos rápidos del Home) con target táctil ≥48dp.
class IconBadgeButton extends StatelessWidget {
  const IconBadgeButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.iconSize = 22,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.bg1, Color.lerp(colors.bg1, Colors.black, 0.32)!],
            ),
            border: Border.all(color: colors.accent.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: colors.accent),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}

/// Botón circular ilustrado a partir de un asset propio (ej. el engranaje de
/// ajustes) — sin variante "presionado" dedicada, así que el feedback táctil
/// es escala + opacidad en vez de swap de imagen.
class AssetIconButton extends StatefulWidget {
  const AssetIconButton({
    super.key,
    required this.asset,
    required this.onPressed,
    this.size = 48,
    this.tooltip,
  });

  final String asset;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;

  @override
  State<AssetIconButton> createState() => _AssetIconButtonState();
}

class _AssetIconButtonState extends State<AssetIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Opacity(
            opacity: _pressed ? 0.85 : 1.0,
            child: Image.asset(
              widget.asset,
              width: widget.size,
              height: widget.size,
            ),
          ),
        ),
      ),
    );
    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: button)
        : button;
  }
}

/// Botón "Volver" ilustrado (boton_volver.png) — reemplaza la flecha de back
/// por defecto del `AppBar` en las pantallas secundarias. Dispara una sola
/// vez: tras el primer toque ignora toques repetidos mientras la
/// navegación de salida está en curso (la pantalla se desmonta al hacer
/// pop, así que no hace falta reactivar el flag).
/// Botón de cierre (boton_cerrar.png) para paneles superpuestos que se
/// cierran sin navegar a otra pantalla (diálogos propios, overlays sobre
/// el juego). El ícono visual es chico pero el área táctil es más grande
/// ([tapSize], centrada) — accesible aunque el arte no ocupe todo el
/// target. Un solo disparo: como el panel se desmonta al cerrar, no hace
/// falta reactivar el flag.
class PanelCloseButton extends StatefulWidget {
  const PanelCloseButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.tapSize = 44,
    this.iconSize = 30,
  });

  final VoidCallback onPressed;
  final String? tooltip;
  final double tapSize;
  final double iconSize;

  @override
  State<PanelCloseButton> createState() => _PanelCloseButtonState();
}

class _PanelCloseButtonState extends State<PanelCloseButton> {
  bool _fired = false;
  bool _pressed = false;

  void _handleTap() {
    if (_fired) return;
    _fired = true;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: SizedBox(
          width: widget.tapSize,
          height: widget.tapSize,
          child: Center(
            child: AnimatedScale(
              scale: _pressed ? 0.88 : 1.0,
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              child: Image.asset(
                'assets/images/ui/boton_cerrar.png',
                width: widget.iconSize,
                height: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: button)
        : button;
  }
}

class WoodBackButton extends StatefulWidget {
  const WoodBackButton({super.key, this.onPressed, this.tooltip});

  /// Acción a ejecutar. Si es null, hace `Navigator.maybePop(context)`.
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  State<WoodBackButton> createState() => _WoodBackButtonState();
}

class _WoodBackButtonState extends State<WoodBackButton> {
  bool _fired = false;

  void _handleTap() {
    if (_fired) return;
    _fired = true;
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: AssetIconButton(
        asset: 'assets/images/ui/boton_volver.png',
        size: 42,
        tooltip: widget.tooltip,
        onPressed: _handleTap,
      ),
    );
  }
}

/// Placa de madera vacía (contenedor_contador.png) — base de los contadores
/// de monedas y puntos. `child` va centrado sobre la madera.
///
/// El padding horizontal es una *fracción* del ancho renderizado (no un
/// valor fijo en px): el canal interior liso del PNG arranca recién a
/// ~24% del ancho total (el resto son el marco dorado y las hojas de la
/// esquina), así que un padding fijo se queda corto en placas chicas y
/// deja el contenido pisando el marco — con montos de 5+ cifras (miles de
/// monedas) eso se nota mucho más.
class CounterPlate extends StatelessWidget {
  const CounterPlate({
    super.key,
    required this.child,
    this.width,
    this.horizontalInsetFraction = 0.24,
  });

  final Widget child;
  final double? width;
  final double horizontalInsetFraction;

  @override
  Widget build(BuildContext context) {
    final plate = AspectRatio(
      aspectRatio: 2172 / 724,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth * horizontalInsetFraction;
          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/ui/contenedor_contador.png',
                fit: BoxFit.fill,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: child,
              ),
            ],
          );
        },
      ),
    );
    return width != null ? SizedBox(width: width, child: plate) : plate;
  }
}

/// Ícono de moneda + cantidad sobre la placa de madera, usado en todo el
/// HUD/tienda en vez del emoji/ícono suelto.
class CoinLabel extends StatelessWidget {
  const CoinLabel({
    super.key,
    required this.amount,
    this.iconSize = 16,
    this.style,
    this.prefix = '',
    this.plated = true,
    this.width = 116,
  });

  final int amount;
  final double iconSize;
  final TextStyle? style;

  /// Texto antes del número, ej. '+' en la pantalla de resultado.
  final String prefix;

  /// Si es false, muestra solo ícono + texto sin la placa de madera (para
  /// contextos ya envueltos en su propio panel).
  final bool plated;

  /// Ancho de la placa cuando [plated] es true.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/ui/icono_moneda.png',
          width: iconSize,
          height: iconSize,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$prefix$amount', style: style),
          ),
        ),
      ],
    );
    if (!plated) return row;
    return CounterPlate(width: width, child: row);
  }
}

/// Número de puntos/score sobre la placa de madera — usado para el score
/// final de Resultado. El HUD de juego compone su propia versión animada
/// directamente sobre [CounterPlate] (necesita el estado ×2 del multiplier).
/// Contenedor de HUD reutilizable (marco_contador_hud.png) — mismo
/// componente para puntuación, récord y monedas; solo cambia [iconAsset] y
/// [value]. El círculo tallado a la izquierda del PNG aloja el ícono
/// (medido sobre el asset real); el valor numérico va en el cuerpo, con
/// `FittedBox` para que un número grande se achique en vez de cortarse o
/// desbordar. No es responsabilidad de este widget respetar el área
/// segura — el caller lo ubica dentro de su propio `SafeArea`, igual que
/// ya hacía el HUD existente.
class HudCounter extends StatelessWidget {
  const HudCounter({
    super.key,
    required this.value,
    this.iconAsset,
    this.width = 150,
    this.valueColor,
  });

  final String value;
  final String? iconAsset;
  final double width;
  final Color? valueColor;

  static const _aspect = 1983 / 793;
  // Fracciones medidas sobre marco_contador_hud.png (canvas 1983×793): el
  // círculo tallado para el ícono y la franja de cuerpo donde va el texto.
  static const _iconCenterX = 0.206;
  static const _iconCenterY = 0.49;
  static const _iconDiameter = 0.145;
  static const _textLeft = 0.33;
  static const _textRight = 0.09;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: _aspect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final iconSize = w * _iconDiameter;
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/ui/marco_contador_hud.png',
                  fit: BoxFit.fill,
                ),
                if (iconAsset != null)
                  Positioned(
                    left: w * _iconCenterX - iconSize / 2,
                    top: h * _iconCenterY - iconSize / 2,
                    width: iconSize,
                    height: iconSize,
                    child: Image.asset(iconAsset!, fit: BoxFit.contain),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * _textLeft,
                    0,
                    w * _textRight,
                    0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        // Fijo, no `colors.text0`: el fondo es arte de
                        // madera constante, no cambia con el tema.
                        color: valueColor ?? woodPlateTextPrimary,
                        shadows: _signTextShadow,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PointsCounter extends StatelessWidget {
  const PointsCounter({
    super.key,
    required this.value,
    this.fontSize = 44,
    this.width = 220,
    this.color,
    this.showTrophy = true,
    this.trophySize = 26,
  });

  final int value;
  final double fontSize;
  final double width;
  final Color? color;

  /// Ícono de trofeo (récord/puntos) a la izquierda del número.
  final bool showTrophy;
  final double trophySize;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final number = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '$value',
        style: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: color ?? colors.text0,
          height: 1,
        ),
      ),
    );
    return CounterPlate(
      width: width,
      child: !showTrophy
          ? number
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ui/icono_puntos.png',
                  width: trophySize,
                  height: trophySize,
                ),
                const SizedBox(width: 8),
                Flexible(child: number),
              ],
            ),
    );
  }
}

/// Ícono de trofeo (récord/mejor puntaje) — para acompañar textos de "Best
/// score" fuera de una placa de madera (Home, HUD de juego, Stats).
class TrophyIcon extends StatelessWidget {
  const TrophyIcon({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/icono_puntos.png',
      width: size,
      height: size,
    );
  }
}

/// Preview circular de una skin: usa su sprite si tiene, o el color como
/// respaldo. Compartido entre `SkinsScreen` y `ShopScreen`.
class SkinPreview extends StatelessWidget {
  const SkinPreview({super.key, required this.skin, this.size = 42});

  final SkinDef skin;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = skin.spriteAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        width: size,
        height: size,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => _colorFallback(),
      );
    }
    return _colorFallback();
  }

  Widget _colorFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: skin.ghost ? skin.color.withValues(alpha: 0.5) : skin.color,
        border: skin.secondary != null
            ? Border.all(color: skin.secondary!, width: 2)
            : null,
      ),
    );
  }
}

/// Ícono de diamante (rareza) coloreado — usado para destacar skins de
/// Tienda. [tint] elige el asset más cercano entre los diamantes disponibles.
class RarityDiamond extends StatelessWidget {
  const RarityDiamond({super.key, required this.color, this.size = 18});

  final Color color;
  final double size;

  // Categorías que ya tienen su gema ilustrada propia (gema_rareza_*.png)
  // en vez del diamante plano original.
  static const _gemOverrides = {
    'diamond_green': 'gema_rareza_verde',
    'diamond_violet': 'gema_rareza_violeta',
    'diamond_red': 'gema_rareza_roja',
    'diamond_blue': 'gema_rareza_azul',
  };

  @override
  Widget build(BuildContext context) {
    final key = _closestDiamond(color);
    final gem = _gemOverrides[key];
    return Image.asset(
      gem != null ? 'assets/images/ui/$gem.png' : 'assets/images/ui/$key.png',
      width: size,
      height: size,
      filterQuality: gem != null ? FilterQuality.medium : FilterQuality.none,
    );
  }

  static String _closestDiamond(Color c) {
    final options = {
      'diamond_red': const Color(0xFFEF4444),
      'diamond_green': const Color(0xFF22C55E),
      'diamond_blue': const Color(0xFF0EA5E9),
      'diamond_pink': const Color(0xFFEC4899),
      'diamond_orange': const Color(0xFFF59E0B),
      'diamond_gray': const Color(0xFF94A3B8),
      // Único caso violeta del catálogo hoy (skin Tiyanak) — antes caía
      // en "gray" por ser el más cercano entre las 6 categorías
      // originales; con esta entrada matchea exacto.
      'diamond_violet': const Color(0xFFA855F7),
    };
    var best = options.keys.first;
    var bestDist = double.infinity;
    for (final entry in options.entries) {
      final dr = c.r - entry.value.r;
      final dg = c.g - entry.value.g;
      final db = c.b - entry.value.b;
      final dist = dr * dr + dg * dg + db * db;
      if (dist < bestDist) {
        bestDist = dist;
        best = entry.key;
      }
    }
    return best;
  }
}

/// Botón secundario ilustrado (boton_secundario.png) — para acciones tipo
/// "Cancelar"/"Cerrar"/"Más tarde": un solo estado de imagen (sin variante
/// presionada propia), así que el feedback táctil es escala al tocar.
/// Texto vía el sistema de localización del proyecto (`t.xxx` pasado por
/// el caller), centrado y auto-ajustable con `FittedBox` para que cualquier
/// traducción entre sin desbordar. Toda la superficie es la zona pulsable
/// (`GestureDetector` opaco) con target accesible (alto mínimo 44). Un
/// solo disparo por instancia: evita que un doble toque accidental repita
/// la acción mientras el panel que la contiene se cierra.
/// Botón principal ilustrado (boton_primario.png) — para acciones tipo
/// "Aceptar"/"Confirmar"/"Comprar"/"Continuar": mismo patrón que
/// [SecondaryActionButton] (un solo estado de imagen, escala al tocar,
/// texto centrado auto-ajustable vía `t.xxx`, superficie completa pulsable
/// con target accesible, un solo disparo por instancia). Se diferencia por
/// el borde verde del cartel — para la acción afirmativa, no la de
/// cancelar.
class PrimaryActionButton extends StatefulWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 160,
  });

  final String label;

  /// Null deshabilita el botón por completo: swap automático a
  /// boton_primario_deshabilitado.png (mismas dimensiones, sin deformar ni
  /// mover nada del layout), sin gestos ni feedback táctil, y expuesto
  /// como tal a accesibilidad (`Semantics.enabled: false`).
  final VoidCallback? onPressed;
  final double width;

  @override
  State<PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<PrimaryActionButton> {
  bool _fired = false;
  bool _pressed = false;

  void _handleTap() {
    if (_fired) return;
    _fired = true;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            child: AspectRatio(
              // Misma proporción en ambos PNG — no se deforma ni cambia de
              // tamaño al pasar de uno a otro (sin saltos de layout).
              aspectRatio: 2172 / 724,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    enabled
                        ? 'assets/images/ui/boton_primario.png'
                        : 'assets/images/ui/boton_primario_deshabilitado.png',
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: enabled
                              ? woodPlateTextPrimary
                              : _signTextDisabled,
                          shadows: _signTextShadow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatefulWidget {
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 160,
  });

  final String label;

  /// Null deshabilita el botón por completo: swap automático a
  /// boton_secundario_deshabilitado.png, sin gestos ni feedback táctil, y
  /// expuesto como tal a accesibilidad (`Semantics.enabled: false`).
  final VoidCallback? onPressed;
  final double width;

  @override
  State<SecondaryActionButton> createState() => _SecondaryActionButtonState();
}

class _SecondaryActionButtonState extends State<SecondaryActionButton> {
  bool _fired = false;
  bool _pressed = false;

  void _handleTap() {
    if (_fired) return;
    _fired = true;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            child: AspectRatio(
              // Misma proporción en ambos PNG — no se deforma ni cambia de
              // tamaño al pasar de uno a otro.
              aspectRatio: 2172 / 724,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    enabled
                        ? 'assets/images/ui/boton_secundario.png'
                        : 'assets/images/ui/boton_secundario_deshabilitado.png',
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: enabled
                              ? woodPlateTextPrimary
                              : _signTextDisabled,
                          shadows: _signTextShadow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenido ilustrado (banda_notificacion.png) para mensajes breves del
/// sistema — se usa como `content` de un `SnackBar` normal (ver
/// [showWoodSnackBar]), así que hereda el comportamiento de aparición/
/// desaparición/swipe-to-dismiss que Flutter ya trae para SnackBar, sin
/// efectos nuevos. El hueco tallado a la izquierda del PNG aloja
/// [iconAsset] cuando se pasa; el mensaje ocupa el resto, ajustado con
/// wrap + `maxLines` para no desbordar nunca el cartel.
class NotificationBanner extends StatelessWidget {
  const NotificationBanner({
    super.key,
    required this.message,
    this.iconAsset,
    this.fontSize = 14,
  });

  final String message;
  final String? iconAsset;
  final double fontSize;

  static const _slotCenterFraction = 0.13;
  static const _slotSizeFraction = 0.12;
  static const _textLeftFraction = 0.225;
  static const _textRightFraction = 0.06;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2172 / 724,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final iconSize = w * _slotSizeFraction;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/ui/banda_notificacion.png',
                fit: BoxFit.fill,
              ),
              if (iconAsset != null)
                Positioned(
                  left: w * _slotCenterFraction - iconSize / 2,
                  top: h / 2 - iconSize / 2,
                  width: iconSize,
                  height: iconSize,
                  child: Image.asset(iconAsset!, fit: BoxFit.contain),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  w * _textLeftFraction,
                  0,
                  w * _textRightFraction,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: woodPlateTextPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
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

/// Muestra un [NotificationBanner] a través del `SnackBar` estándar del
/// proyecto — misma duración/dismiss/no-bloqueo de siempre, solo cambia el
/// contenido visual. Recibe el `ScaffoldMessengerState` ya resuelto (no un
/// `BuildContext`) para respetar el mismo patrón que ya usan los call
/// sites existentes (resolverlo *antes* de un `await`, nunca después).
void showWoodSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  String? iconAsset,
}) {
  messenger.showSnackBar(
    SnackBar(
      content: NotificationBanner(message: message, iconAsset: iconAsset),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

/// Panel de confirmación reutilizable (panel_confirmacion.png) — título +
/// descripción nativos/traducibles, [PrimaryButton] existente para
/// confirmar y [SecondaryActionButton] (boton_secundario.png) para
/// cancelar, con [PanelCloseButton] (boton_cerrar.png) arriba a la derecha.
/// Se muestra con [showConfirmationPanel]; no se usa directamente.
class ConfirmationPanel extends StatefulWidget {
  const ConfirmationPanel({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<ConfirmationPanel> createState() => _ConfirmationPanelState();
}

class _ConfirmationPanelState extends State<ConfirmationPanel> {
  bool _deciding = false;

  void _decide(bool value) {
    if (_deciding) return;
    setState(() => _deciding = true);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 380),
          child: AspectRatio(
            // Proporción original de panel_confirmacion.png — no se
            // deforma.
            aspectRatio: 1448 / 1086,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/ui/panel_confirmacion.png',
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: woodPlateTextPrimary,
                          shadows: _signTextShadow,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: woodPlateTextSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SecondaryActionButton(
                            label: widget.cancelLabel,
                            width: 130,
                            onPressed: _deciding ? null : () => _decide(false),
                          ),
                          const SizedBox(width: 12),
                          PrimaryActionButton(
                            label: widget.confirmLabel,
                            width: 150,
                            onPressed: _deciding ? null : () => _decide(true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: PanelCloseButton(
                    tooltip: widget.cancelLabel,
                    onPressed: () => _decide(false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra un [ConfirmationPanel] y devuelve `true` solo si el usuario
/// confirmó explícitamente — cancelar, tocar afuera, cerrar con la X o
/// usar la navegación atrás devuelven `false` (todos son "no confirmado",
/// misma semántica).
Future<bool> showConfirmationPanel(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => ConfirmationPanel(
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
  return result ?? false;
}

class SubtleLink extends StatelessWidget {
  const SubtleLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: context.oneColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
