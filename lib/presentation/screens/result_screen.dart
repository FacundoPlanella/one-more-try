import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/game_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/sliced_image.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/progression/progression_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.coins,
    required this.apply,
  });

  final int score;
  final int coins;
  final ProgressionApplyResult apply;

  @override
  Widget build(BuildContext context) {
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);
    final d = context.responsive;
    final contentWidth = ResponsiveDimens.contentWidthOf(context);
    final actionWidth = (contentWidth *
            ResponsiveDimens.actionButtonWidthFraction)
        .clamp(contentWidth * 0.55, contentWidth * 0.75)
        .toDouble();
    final actionHeight = d.playButtonHeight;
    final scoreWidth = d.scaledSize(240, min: 240);

    return BannerScaffold(
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_resultado.png',
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: d.horizontalMargin * 0.5),
        child: Column(
          children: [
            const Spacer(flex: 1),
            if (apply.newBest)
              Text(
                t.newBest,
                style: GoogleFonts.outfit(
                  color: colors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: d.scaledFont(18, min: 16),
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(
                      color: Color(0x731B0F06),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            SizedBox(height: d.spacing * 0.6),
            PointsCounter(
              value: score,
              width: scoreWidth,
              fontSize: d.scaledFont(48, min: 36),
              trophySize: d.scaledSize(26, min: 24),
            ),
            SizedBox(height: d.spacing),
            if (apply.dailyJustCompleted)
              _Chip(text: t.dailyMissionComplete, color: colors.success),
            if (apply.newMedals.isNotEmpty)
              _Chip(text: t.medalUnlocked, color: colors.accent),
            if (apply.newSkins.isNotEmpty)
              _Chip(
                text: t.newSkinUnlocked,
                color: colors.accent,
                icon: 'assets/images/ui/chest.png',
              ),
            if (apply.newTitle != null)
              _Chip(
                text: t.titlePrefix(
                  TitleLabel.resolve(context, apply.newTitle!),
                ),
                color: colors.accent,
              ),
            const Spacer(flex: 1),
            PrimaryButton(
              label: t.playAgain,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const GameScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: d.spacing * 0.7),
            _ResultActionButton(
              asset: 'assets/images/ui/boton_compartir_puntaje.png',
              nativeWidth: 2032,
              nativeHeight: 774,
              iconRightFraction: 0.22,
              label: t.shareScore,
              width: actionWidth,
              height: actionHeight,
              onPressed: () => _shareScore(context),
            ),
            SizedBox(height: d.spacing * 0.7),
            _ResultActionButton(
              asset: 'assets/images/ui/boton_menu.png',
              nativeWidth: 1817,
              nativeHeight: 866,
              iconRightFraction: 0.19,
              label: t.menu,
              width: actionWidth,
              height: actionHeight,
              onPressed: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                  ),
                  (_) => false,
                );
              },
            ),
            SizedBox(height: d.spacing),
          ],
        ),
      ),
    );
  }

  Future<void> _shareScore(BuildContext context) async {
    final t = AppLocalizations.of(context);
    await SharePlus.instance.share(
      ShareParams(
        text: '${t.shareScoreMessage(score)}\n${GameConstants.playStoreUrl}',
      ),
    );
  }
}

class _ResultActionButton extends StatefulWidget {
  const _ResultActionButton({
    required this.asset,
    required this.nativeWidth,
    required this.nativeHeight,
    required this.iconRightFraction,
    required this.label,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  final String asset;
  final double nativeWidth;
  final double nativeHeight;
  final double iconRightFraction;
  final String label;
  final double width;
  final double height;
  final Future<void> Function() onPressed;

  @override
  State<_ResultActionButton> createState() => _ResultActionButtonState();
}

class _ResultActionButtonState extends State<_ResultActionButton> {
  bool _pressed = false;
  bool _busy = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textLeft = widget.width * widget.iconRightFraction + 8;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _busy ? null : _handleTap,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: Opacity(
              opacity: _busy ? 0.85 : 1.0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: HorizontalSliceImage(
                      asset: widget.asset,
                      nativeWidth: widget.nativeWidth,
                      nativeHeight: widget.nativeHeight,
                    ),
                  ),
                  Positioned(
                    left: textLeft,
                    right: widget.width * 0.06,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          style: GoogleFonts.outfit(
                            fontSize: widget.height * 0.32,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final d = context.responsive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Image.asset(
                icon!,
                width: 18,
                height: 18,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.manrope(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: d.scaledFont(13, min: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
