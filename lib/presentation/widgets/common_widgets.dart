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

/// Ícono de moneda + cantidad, usado en todo el HUD/tienda en vez del emoji.
class CoinLabel extends StatelessWidget {
  const CoinLabel({
    super.key,
    required this.amount,
    this.iconSize = 16,
    this.style,
    this.prefix = '',
  });

  final int amount;
  final double iconSize;
  final TextStyle? style;

  /// Texto antes del número, ej. '+' en la pantalla de resultado.
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/ui/coin.png',
          width: iconSize,
          height: iconSize,
          filterQuality: FilterQuality.none,
        ),
        const SizedBox(width: 4),
        Text('$prefix$amount', style: style),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/${_closestDiamond(color)}.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
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
