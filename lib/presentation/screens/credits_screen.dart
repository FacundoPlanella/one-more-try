import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            Text(
              t.creditsHeading,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colors.text0,
              ),
            ),
            const SizedBox(height: 28),
            Image.asset(
              'assets/images/creatures/players/default.png',
              width: 64,
              height: 64,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(height: 20),
            _CreditBlock(
              colors: colors,
              label: t.pixelArtLabel,
              title: t.philippineMythCreatures,
              author: t.byShade,
              note: t.cc0Note,
              linkLabel: t.viewOnItch,
              onViewPack: _openShadePack,
            ),
            const SizedBox(height: 32),
            _CreditBlock(
              colors: colors,
              label: t.uiArtLabel,
              title: t.superRetroWorldPack,
              author: t.bySuperRetroAuthors,
              note: t.superRetroLicenseNote,
              linkLabel: t.viewOnItch,
              onViewPack: _openSuperRetroPack,
            ),
            const SizedBox(height: 40),
            Text(
              t.gameByPlanella,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.fromSettings)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.back),
              )
            else
              Text(
                t.loading,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: colors.text1.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.bg0,
              Color.lerp(colors.bg0, colors.accent, 0.1)!,
            ],
          ),
        ),
        child: body,
      ),
    );
  }
}

/// Un bloque de atribución (label + nombre del pack + autor + nota de
/// licencia + link) — usado una vez por cada pack de terceros que el juego
/// usa, para no repetir el layout.
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
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: colors.text1,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.text0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          author,
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: colors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          note,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: colors.text1,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onViewPack,
          child: Text(
            linkLabel,
            style: GoogleFonts.manrope(color: colors.accent),
          ),
        ),
      ],
    );
  }
}
