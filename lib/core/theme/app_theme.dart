import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const bg0 = AppColors.darkBg0;
    const bg1 = AppColors.darkBg1;
    const text0 = AppColors.darkText0;
    const text1 = AppColors.darkText1;
    const accent = AppColors.darkAccent;
    const danger = AppColors.darkDanger;
    const success = AppColors.darkSuccess;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg0,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: accent,
        onPrimary: bg0,
        secondary: accent,
        onSecondary: bg0,
        error: danger,
        onError: Colors.white,
        surface: bg1,
        onSurface: text0,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: text0,
        displayColor: text0,
      ),
      primaryTextTheme: GoogleFonts.outfitTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: bg0,
        foregroundColor: text0,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: text0,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: text1.withValues(alpha: 0.2),
      extensions: const [
        OneThemeExtension(
          bg0: bg0,
          bg1: bg1,
          text0: text0,
          text1: text1,
          accent: accent,
          danger: danger,
          success: success,
          lane: AppColors.darkLane,
          obstacle: AppColors.darkObstacle,
        ),
      ],
    );
  }
}

@immutable
class OneThemeExtension extends ThemeExtension<OneThemeExtension> {
  const OneThemeExtension({
    required this.bg0,
    required this.bg1,
    required this.text0,
    required this.text1,
    required this.accent,
    required this.danger,
    required this.success,
    required this.lane,
    required this.obstacle,
  });

  final Color bg0;
  final Color bg1;
  final Color text0;
  final Color text1;
  final Color accent;
  final Color danger;
  final Color success;
  final Color lane;
  final Color obstacle;

  @override
  OneThemeExtension copyWith({
    Color? bg0,
    Color? bg1,
    Color? text0,
    Color? text1,
    Color? accent,
    Color? danger,
    Color? success,
    Color? lane,
    Color? obstacle,
  }) {
    return OneThemeExtension(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      text0: text0 ?? this.text0,
      text1: text1 ?? this.text1,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      lane: lane ?? this.lane,
      obstacle: obstacle ?? this.obstacle,
    );
  }

  @override
  OneThemeExtension lerp(ThemeExtension<OneThemeExtension>? other, double t) {
    if (other is! OneThemeExtension) return this;
    return OneThemeExtension(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      text0: Color.lerp(text0, other.text0, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      lane: Color.lerp(lane, other.lane, t)!,
      obstacle: Color.lerp(obstacle, other.obstacle, t)!,
    );
  }
}

extension OneThemeContext on BuildContext {
  OneThemeExtension get oneColors =>
      Theme.of(this).extension<OneThemeExtension>()!;
}
