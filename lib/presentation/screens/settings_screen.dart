import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/game_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/panel_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'credits_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languageNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '中文',
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final save = app.save;
    final t = AppLocalizations.of(context);

    return BannerScaffold(
      appBar: AppBar(
        leading: WoodBackButton(tooltip: t.back),
        title: Text(t.settingsTitle),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          context.responsive.listBottomPadding,
        ),
        children: [
          _SettingsRow(
            iconAsset: 'assets/images/ui/icono_musica.png',
            label: t.music,
            onTap: () => app.setMusic(!save.music),
            trailing: _RowToggle(value: save.music, onChanged: app.setMusic),
          ),
          const SizedBox(height: 10),
          _SettingsRow(
            iconAsset: 'assets/images/ui/icono_sonido.png',
            label: t.soundEffects,
            onTap: () => app.setSfx(!save.sfx),
            trailing: _RowToggle(value: save.sfx, onChanged: app.setSfx),
          ),
          const SizedBox(height: 10),
          _SettingsRow(
            iconAsset: 'assets/images/ui/icono_vibracion.png',
            label: t.haptics,
            onTap: () => app.setHaptics(!save.haptics),
            trailing: _RowToggle(
              value: save.haptics,
              onChanged: app.setHaptics,
            ),
          ),
          const SizedBox(height: 10),
          _SettingsRow(
            icon: Icons.accessibility_new_rounded,
            label: t.reduceMotion,
            onTap: () => app.setReduceMotion(!save.reduceMotion),
            // Mismo control ilustrado que Música/Sonido/Vibración (antes
            // usaba el `Switch` de Material sin estilizar: mismo dato
            // booleano, dos controles visual y táctilmente distintos en la
            // misma pantalla).
            trailing: _RowToggle(
              value: save.reduceMotion,
              onChanged: app.setReduceMotion,
            ),
          ),
          const SizedBox(height: 10),
          _LanguageRow(
            currentCode: save.languageCode,
            currentLabel: _languageNames[save.languageCode] ?? 'English',
            optionNames: _languageNames,
            onChanged: app.setLanguageCode,
          ),
          const SizedBox(height: 10),
          _HowToPlayRow(label: t.howToPlay),
          const SizedBox(height: 10),
          _RateAppRow(label: t.rateApp),
          const SizedBox(height: 10),
          _ContactSupportRow(label: t.contactSupport),
          const SizedBox(height: 10),
          _AboutRow(label: t.about),
          const SizedBox(height: 10),
          _SettingsRow(
            iconAsset: 'assets/images/ui/icono_creditos.png',
            label: t.credits,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreditsScreen(fromSettings: true),
                ),
              );
            },
            trailing: const _RowChevron(),
          ),
          const SizedBox(height: 10),
          _PrivacyPolicyRow(label: t.privacyPolicy),
          const SizedBox(height: 10),
          _TermsRow(label: t.termsAndConditions),
          const SizedBox(height: 10),
          _ShareGameRow(label: t.shareGame),
        ],
      ),
    );
  }
}

/// Fila de Idioma: usa selector_idioma.png (en vez de fila_configuracion.png
/// + _RowValue genérico) como control dedicado a la derecha — el nombre
/// del idioma va centrado en el espacio libre a la izquierda de la flecha,
/// que ya viene dibujada en el propio PNG. `_busy` bloquea toques
/// repetidos mientras la hoja de selección está abierta.
class _LanguageRow extends StatefulWidget {
  const _LanguageRow({
    required this.currentCode,
    required this.currentLabel,
    required this.optionNames,
    required this.onChanged,
  });

  final String currentCode;
  final String currentLabel;
  final Map<String, String> optionNames;
  final ValueChanged<String> onChanged;

  @override
  State<_LanguageRow> createState() => _LanguageRowState();
}

class _LanguageRowState extends State<_LanguageRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = await showDialog<String>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => _LanguagePanel(
          current: widget.currentCode,
          options: [
            for (final code in widget.optionNames.keys)
              (code, widget.optionNames[code]!),
          ],
        ),
      );
      if (next != null) widget.onChanged(next);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_idioma.png',
      label: AppLocalizations.of(context).language,
      onTap: _busy ? null : _handleTap,
      trailing: _LanguageSelectorControl(label: widget.currentLabel),
    );
  }
}

/// Control ilustrado (selector_idioma.png) — nombre del idioma centrado en
/// el tramo izquierdo/central del cartel, con la flecha derecha (ya
/// dibujada en el PNG) siempre libre de texto. Ancho fijo con tipografía
/// que se auto-ajusta (`FittedBox`) para que cualquier idioma entre sin
/// desbordar ni deformar el cartel.
class _LanguageSelectorControl extends StatelessWidget {
  const _LanguageSelectorControl({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AspectRatio(
        aspectRatio: 2172 / 724,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/ui/selector_idioma.png',
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 42),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.manrope(
                    color: woodPlateTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción ilustrada dentro de la hoja de selección (opcion_selector_idioma
/// .png) — nombre del idioma a la izquierda, marca_seleccion.png reservada
/// a la derecha solo en la opción activa. Toda la superficie es pulsable.
/// Panel superpuesto (panel_selector_idioma.png) para elegir idioma —
/// diálogo centrado con título nativo y las filas ilustradas de siempre,
/// con scroll interno si no entran todas. No toca el fondo existente
/// (la pantalla de Configuración sigue detrás, solo se agrega el scrim de
/// diálogo estándar). Cierra solo: al elegir una opción, al tocar afuera
/// (`barrierDismissible` por defecto de `showDialog`) o con el botón
/// atrás del sistema (ambos ya vienen gratis del mecanismo de rutas).
class _LanguagePanel extends StatefulWidget {
  const _LanguagePanel({required this.current, required this.options});

  final String current;
  final List<(String value, String label)> options;

  @override
  State<_LanguagePanel> createState() => _LanguagePanelState();
}

class _LanguagePanelState extends State<_LanguagePanel> {
  bool _selecting = false;

  void _select(String value) {
    if (_selecting) return;
    setState(() => _selecting = true);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SafeArea(
        // maxWidth/maxHeight son techos para pantallas grandes, no un
        // tamaño fijo: en una pantalla chica o baja (o con fuente de
        // sistema agrandada), `constraints` ya viene acotado por el
        // espacio real disponible tras `insetPadding`, así que topar ahí
        // en vez de en el valor fijo evita que el panel se recorte o se
        // desborde. El título es fijo y la lista de idiomas ya scrollea
        // (`Flexible` + `SingleChildScrollView` más abajo).
        child: LayoutBuilder(
          builder: (context, constraints) {
            const aspectRatio = 1086 / 1448;
            final panel = PanelMetrics.resolve(
              context,
              constraints: constraints,
              designWidth: 340,
              designHeight: 480,
              aspectRatio: aspectRatio,
            );
            final s = panel.scale;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: panel.maxWidth,
                maxHeight: panel.maxHeight,
              ),
              child: AspectRatio(
                // Proporción original de panel_selector_idioma.png — no se
                // deforma.
                aspectRatio: aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/ui/panel_selector_idioma.png',
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(22 * s, 34 * s, 22 * s, 26 * s),
                      child: Column(
                        children: [
                          Padding(
                            // Deja libre, a la derecha, el margen que ocupa
                            // el botón de cierre superpuesto.
                            padding: EdgeInsets.only(right: 34 * s),
                            child: Text(
                              t.language,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 20 * s,
                                fontWeight: FontWeight.w800,
                                color: woodPlateTextPrimary,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xCC1B0F06),
                                    offset: Offset(0, 2),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 14 * s),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (final option in widget.options)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8 * s),
                                      child: _IllustratedOptionRow(
                                        asset:
                                            'assets/images/ui/opcion_selector_idioma.png',
                                        label: option.$2,
                                        scale: s,
                                        selected: option.$1 == widget.current,
                                        onTap: _selecting
                                            ? null
                                            : () => _select(option.$1),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 14 * s,
                      right: 14 * s,
                      child: PanelCloseButton(
                        tooltip: t.back,
                        tapSize: 44 * s,
                        iconSize: 30 * s,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IllustratedOptionRow extends StatelessWidget {
  const _IllustratedOptionRow({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
    this.scale = 1,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Escala del panel que la contiene (ver [PanelMetrics.scale]).
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2172 / 724,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.manrope(
                        color: woodPlateTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16 * scale,
                      ),
                    ),
                  ),
                  if (selected)
                    Image.asset(
                      'assets/images/ui/marca_seleccion.png',
                      width: 24 * scale,
                      height: 24 * scale,
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

/// Fila de una opción de Configuración — fila_configuracion.png de fondo
/// (proporción original 1881:836, sin deformar) con ícono + texto a la
/// izquierda y el control (switch/valor/flecha) a la derecha. Toda la fila
/// es la zona pulsable cuando hay [onTap].
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    this.iconAsset,
    required this.label,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  // Medidas nativas de fila_configuracion.png (canvas 1881×836): la tabla
  // real es una franja angosta centrada en un canvas mucho más alto (deja
  // ~70% de margen transparente arriba/abajo). Sin recortar a este bbox,
  // la fila se ve minúscula dentro de sus 60dp con un montón de "espacio
  // muerto" invisible por encima/debajo — justo el bug reportado.
  static const _bgNativeW = 1881.0;
  static const _bgNativeH = 836.0;
  static const _bgContentLeft = 113.0;
  static const _bgContentTop = 289.0;
  static const _bgContentW = 1637.0;
  static const _bgContentH = 249.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final content = SizedBox(
      height: 60,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final scaleX = w / _bgContentW;
          final scaleY = h / _bgContentH;
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -_bgContentLeft * scaleX,
                      top: -_bgContentTop * scaleY,
                      width: _bgNativeW * scaleX,
                      height: _bgNativeH * scaleY,
                      child: Image.asset(
                        'assets/images/ui/fila_configuracion.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    iconAsset != null
                        ? Image.asset(iconAsset!, width: 24, height: 24)
                        : Icon(icon, size: 24, color: colors.accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: woodPlateTextPrimary,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 10),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }
}

/// Toggle ilustrado (interruptor_activado/desactivado.png) para Música,
/// Sonido y Vibración. Alterna al tocar el interruptor mismo; tocar el
/// resto de la fila también alterna vía el `onTap` de [_SettingsRow] —
/// ambos llaman al mismo setter persistente (`app.setMusic`, etc.), no hay
/// estado propio acá.
/// Fila "Calificar aplicación": intenta el diálogo de reseña nativo
/// primero y si no está disponible cae al listado de Google Play. El
/// `_busy` local bloquea toques repetidos mientras esa llamada async está
/// en curso (a diferencia de un back-button que navega y se desmonta, acá
/// el usuario se queda en la pantalla, así que el bloqueo se libera al
/// terminar en vez de ser un disparo único).
class _RateAppRow extends StatefulWidget {
  const _RateAppRow({required this.label});

  final String label;

  @override
  State<_RateAppRow> createState() => _RateAppRowState();
}

class _RateAppRowState extends State<_RateAppRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        return;
      }
      // En Android openStoreListing() no necesita appStoreId: usa el
      // packageName de la app. iosAppStoreId solo aplica si algún día se
      // publica en iOS.
      await inAppReview.openStoreListing(
        appStoreId: GameConstants.iosAppStoreId.isEmpty
            ? null
            : GameConstants.iosAppStoreId,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_calificar_app.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Política de privacidad": abre la URL externa vía `url_launcher`
/// (el mismo mecanismo que ya usaba el proyecto). `_busy` bloquea toques
/// repetidos mientras el launch está en curso; se libera al terminar, no
/// es un disparo único (el usuario se queda en Configuración).
class _PrivacyPolicyRow extends StatefulWidget {
  const _PrivacyPolicyRow({required this.label});

  final String label;

  @override
  State<_PrivacyPolicyRow> createState() => _PrivacyPolicyRowState();
}

class _PrivacyPolicyRowState extends State<_PrivacyPolicyRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final messenger = ScaffoldMessenger.of(context);
      final opened = await launchUrl(
        Uri.parse(GameConstants.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        showWoodSnackBar(
          messenger,
          message: GameConstants.privacyPolicyUrl,
          iconAsset: 'assets/images/ui/icono_advertencia.png',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_privacidad.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Cómo jugar": abre el mismo diálogo de tutorial que ya existía.
/// `_busy` se libera cuando `showDialog` resuelve (al cerrar el diálogo
/// con "Entendido" o tocando afuera), bloqueando toques repetidos
/// mientras está abierto.
class _HowToPlayRow extends StatefulWidget {
  const _HowToPlayRow({required this.label});

  final String label;

  @override
  State<_HowToPlayRow> createState() => _HowToPlayRowState();
}

class _HowToPlayRowState extends State<_HowToPlayRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bg1,
        title: Text(t.tutorialTitle),
        content: Text(t.tutorialSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.gotIt),
          ),
        ],
      ),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_ayuda.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Contacto y soporte": abre el cliente de mail (`mailto:`) con
/// destinatario y asunto ya definidos en `GameConstants` — mismo mecanismo
/// que ya existía. `_busy` bloquea toques repetidos mientras se resuelve
/// `launchUrl`.
class _ContactSupportRow extends StatefulWidget {
  const _ContactSupportRow({required this.label});

  final String label;

  @override
  State<_ContactSupportRow> createState() => _ContactSupportRowState();
}

class _ContactSupportRowState extends State<_ContactSupportRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final messenger = ScaffoldMessenger.of(context);
      final t = AppLocalizations.of(context);
      final uri = Uri(
        scheme: 'mailto',
        path: GameConstants.supportEmail,
        queryParameters: {
          'subject': t.contactSupportEmailSubject(GameConstants.appName),
        },
      );
      final opened = await launchUrl(uri);
      if (!opened) {
        showWoodSnackBar(
          messenger,
          message: GameConstants.supportEmail,
          iconAsset: 'assets/images/ui/icono_advertencia.png',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_contacto_soporte.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Compartir juego": abre el selector nativo de compartir
/// (`share_plus`, el mismo paquete que ya usa Resultado para compartir el
/// puntaje) con el link oficial de Play Store y un mensaje traducible
/// definido en código. `_busy` se libera cuando el selector se cierra (el
/// `Future` de `share()` resuelve ahí).
class _ShareGameRow extends StatefulWidget {
  const _ShareGameRow({required this.label});

  final String label;

  @override
  State<_ShareGameRow> createState() => _ShareGameRowState();
}

class _ShareGameRowState extends State<_ShareGameRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final t = AppLocalizations.of(context);
      await SharePlus.instance.share(
        ShareParams(
          text: '${t.shareGameMessage}\n${GameConstants.playStoreUrl}',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_compartir.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Acerca del juego": abre la misma pantalla de Créditos existente
/// (nombre del juego, versión implícita en `gameByPlanella` y atribuciones)
/// — no hay una pantalla de "About" separada en el proyecto. `_busy` se
/// activa al empujar la ruta y se libera solo cuando esa ruta vuelve a
/// hacer pop (el `Future` de `Navigator.push` resuelve recién ahí), así
/// que bloquea toques repetidos justo durante la transición de entrada.
class _AboutRow extends StatefulWidget {
  const _AboutRow({required this.label});

  final String label;

  @override
  State<_AboutRow> createState() => _AboutRowState();
}

class _AboutRowState extends State<_AboutRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreditsScreen(fromSettings: true),
      ),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_acerca_del_juego.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

/// Fila "Términos y condiciones". El proyecto todavía no tiene un
/// documento propio de T&C (solo la política de privacidad) — a pedido
/// del usuario, apunta a `GameConstants.privacyPolicyUrl` (mismo
/// mecanismo de `launchUrl`) hasta que exista una URL dedicada.
class _TermsRow extends StatefulWidget {
  const _TermsRow({required this.label});

  final String label;

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final messenger = ScaffoldMessenger.of(context);
      final opened = await launchUrl(
        Uri.parse(GameConstants.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        showWoodSnackBar(
          messenger,
          message: GameConstants.privacyPolicyUrl,
          iconAsset: 'assets/images/ui/icono_advertencia.png',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      iconAsset: 'assets/images/ui/icono_terminos_condiciones.png',
      label: widget.label,
      onTap: _busy ? null : _handleTap,
      trailing: const _RowChevron(),
    );
  }
}

class _RowToggle extends StatelessWidget {
  const _RowToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 52,
        height: 26,
        child: Image.asset(
          value
              ? 'assets/images/ui/interruptor_activado.png'
              : 'assets/images/ui/interruptor_desactivado.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

/// Indicador de navegación al final de las filas de acción/pantalla —
/// puramente visual (nunca envuelto en gesture propio): el toque sigue
/// siendo el de toda la fila vía el `onTap` de [_SettingsRow].
class _RowChevron extends StatelessWidget {
  const _RowChevron();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/flecha_navegacion_derecha.png',
      width: 20,
      height: 20,
    );
  }
}
