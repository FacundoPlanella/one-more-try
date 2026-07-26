import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.bg0,
              Color.lerp(colors.bg0, colors.accent, 0.12)!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandTitle(),
            const SizedBox(height: 12),
            Text(
              'One tap. One life.',
              style: GoogleFonts.manrope(
                color: colors.text1,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
