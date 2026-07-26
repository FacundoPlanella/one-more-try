import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_theme.dart';
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
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(child: child),
          SafeArea(
            top: false,
            child: ads.bannerWidget(),
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
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: colors.text0,
        letterSpacing: -0.5,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final btn = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.bg0,
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      child: Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class SubtleLink extends StatelessWidget {
  const SubtleLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: context.oneColors.text1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
