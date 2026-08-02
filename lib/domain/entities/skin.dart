import 'package:flutter/material.dart';

/// Definición de una skin cosmética (solo visual).
class SkinDef {
  const SkinDef({
    required this.id,
    required this.name,
    required this.color,
    this.secondary,
    this.ghost = false,
    this.dualTrail = false,
    this.prism = false,
    this.spriteAsset,
    this.creatureName,
    this.unlockBestScore,
    this.unlockGamesPlayed,
    this.unlockDailyStreak,
    this.priceCoins,
  });

  final String id;
  final String name;
  final Color color;
  final Color? secondary;
  final bool ghost;
  final bool dualTrail;
  final bool prism;

  /// Idle frame path under Flutter assets, e.g. `assets/images/creatures/players/default.png`.
  final String? spriteAsset;

  /// Myth creature name shown in credits / skins (from Shade's pack).
  final String? creatureName;

  final int? unlockBestScore;
  final int? unlockGamesPlayed;
  final int? unlockDailyStreak;

  /// Si no es null, esta skin se compra en la Tienda con monedas en vez de
  /// desbloquearse por progreso.
  final int? priceCoins;

  bool get isShopExclusive => priceCoins != null;
}
