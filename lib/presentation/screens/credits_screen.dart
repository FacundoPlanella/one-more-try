import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/responsive/app_screen.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

/// Startup attribution for third-party art, then continues to Home.
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.fromSettings) {
      Future<void>.delayed(const Duration(milliseconds: 2800), _continue);
    }
  }

  void _continue() {
    if (!mounted || widget.fromSettings) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _openShadePack() async {
    await launchUrl(
      Uri.parse('https://merchant-shade.itch.io/ph-myth-creatures'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openSuperRetroPack() async {
    await launchUrl(
      Uri.parse('https://gif-superretroworld.itch.io/'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    // Para cuando esta pantalla se monta, SplashScreen ya esperó a
    // `app.ready` — en el flujo normal esto ya está en true. Se lee en
    // vivo (en vez de asumir que siempre lo está) para que el texto de
    // "Cargando…" solo aparezca mientras realmente no hay datos, y
    // desaparezca apenas los haya.
    final ready = context.watch<AppController>().ready;

    final d = context.responsive;
    final header = Padding(
      padding: EdgeInsets.fromLTRB(20, widget.fromSettings ? 8 : 24, 20, 0),
      child: Column(
        children: [
          Center(
            child: TitlePlate(
              text: t.creditsHeading,
              height: d.scaledSize(56, min: 48),
              fontSize: d.scaledFont(24, min: 20),
            ),
          ),
          SizedBox(height: d.spacing),
          Center(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/ui/icono_creditos.png',
                width: d.scaledSize(48, min: 48),
                height: d.scaledSize(48, min: 48),
              ),
            ),
          ),
        ],
      ),
    );

    return AppScreen(
      showBanner: false,
      constrainWidth: true,
      safeTop: true,
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_pantallas_iniciales.png',
      ),
      body: Column(
        children: [
          if (widget.fromSettings)
            Align(
              alignment: Alignment.centerLeft,
              child: WoodBackButton(tooltip: t.back),
            ),
          header,
          SizedBox(height: d.spacing),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, d.listBottomPadding + 16),
              children: [
                _CreditCard(
                  child: _CreditBlock(
                    colors: colors,
                    label: t.pixelArtLabel,
                    title: t.philippineMythCreatures,
                    author: t.byShade,
                    note: t.cc0Note,
                    linkLabel: t.viewOnItch,
                    onViewPack: _openShadePack,
                  ),
                ),
                SizedBox(height: d.spacing),
                const SectionDivider(),
                SizedBox(height: d.spacing),
                _CreditCard(
                  child: _CreditBlock(
                    colors: colors,
                    label: t.uiArtLabel,
                    title: t.superRetroWorldPack,
                    author: t.bySuperRetroAuthors,
                    note: t.superRetroLicenseNote,
                    linkLabel: t.viewOnItch,
                    onViewPack: _openSuperRetroPack,
                  ),
                ),
                SizedBox(height: d.spacing * 2),
                Text(
                  t.gameByPlanella,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: d.scaledFont(13, min: 13),
                    color: colors.text1,
                  ),
                ),
                if (!widget.fromSettings && !ready) ...[
                  const SizedBox(height: 12),
                  Text(
                    t.loading,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: colors.text1.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Envuelve [ContentCard] con un padding vertical que SIEMPRE despeja la
/// "tapa" decorativa dorada del panel (dibujada en la propia imagen de
/// fondo), en vez de un valor fijo.
///
/// Esa tapa escala con el ANCHO de la tarjeta, no con su alto — ver
/// `ContentCard._capH`/`._nativeW` en common_widgets.dart, no expuestos
/// públicamente, así que se replica acá la misma proporción en vez de
/// importarlos. Con un padding vertical fijo (24), el título quedaba
/// dibujado sobre el grabado de la tapa superior y la nota de licencia
/// sobre el de la tapa inferior — ilegibles por el contraste y el patrón
/// del grabado — porque una tarjeta con un solo bloque es bastante más
/// baja que la tarjeta compartida original, y esa tapa (fija en proporción
/// al ancho) pasa a ocupar una porción mucho mayor del alto total.
class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.child});

  final Widget child;

  static const _capFraction = 170.0 / 1096.0;
  static const _capClearance = 14.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding =
            constraints.maxWidth * _capFraction + _capClearance;
        return ContentCard(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: 26,
          ),
          child: child,
        );
      },
    );
  }
}

/// Un bloque de atribución (label + nombre del pack + autor + nota de
/// licencia + link) — usado una vez por cada pack de terceros que el juego
/// usa, para no repetir el layout. Cada instancia vive en su propio
/// [_CreditCard] independiente (ver [_CreditsScreenState.build]), así que
/// se dimensiona sola según su propio contenido sin depender del bloque
/// vecino.
class _CreditBlock extends StatelessWidget {
  const _CreditBlock({
    required this.colors,
    required this.label,
    required this.title,
    required this.author,
    required this.note,
    required this.linkLabel,
    required this.onViewPack,
  });

  final OneThemeExtension colors;
  final String label;
  final String title;
  final String author;
  final String note;
  final String linkLabel;
  final VoidCallback onViewPack;

  @override
  Widget build(BuildContext context) {
    final d = context.responsive;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: colors.text1,
            fontSize: d.scaledFont(13, min: 13),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: d.scaledFont(20, min: 18),
            fontWeight: FontWeight.w700,
            color: colors.text0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          author,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: d.scaledFont(16, min: 15),
            color: colors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          note,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: d.scaledFont(13, min: 13),
            color: colors.text1,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onViewPack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  linkLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                'assets/images/ui/icono_enlace_externo.png',
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
