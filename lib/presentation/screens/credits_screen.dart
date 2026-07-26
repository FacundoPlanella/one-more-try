import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
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

  Future<void> _openPack() async {
    await launchUrl(
      Uri.parse('https://merchant-shade.itch.io/ph-myth-creatures'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              'Credits',
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
            Text(
              'Pixel art',
              style: GoogleFonts.manrope(
                color: colors.text1,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Philippine Myth Creatures',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.text0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by Shade',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CC0 · itch.io pack used with thanks',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _openPack,
              child: Text(
                'View on itch.io',
                style: GoogleFonts.manrope(color: colors.accent),
              ),
            ),
            const Spacer(flex: 2),
            Text(
              'One more try. — Planella',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.fromSettings)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              )
            else
              Text(
                'Loading…',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: colors.text1.withValues(alpha: 0.7),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
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
