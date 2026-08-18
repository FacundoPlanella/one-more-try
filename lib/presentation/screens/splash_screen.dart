import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/app_screen.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'credits_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final app = context.read<AppController>();
    final start = DateTime.now();
    while (!app.ready) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    final elapsed = DateTime.now().difference(start);
    final wait = const Duration(milliseconds: 900) - elapsed;
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const CreditsScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    return AppScreen(
      showBanner: false,
      constrainWidth: true,
      safeTop: true,
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_pantallas_iniciales.png',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).appTagline,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: colors.text1,
                fontSize: context.responsive.scaledFont(15, min: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
