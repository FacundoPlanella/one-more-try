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

  String get unlockHint {
    if (unlockBestScore != null) return 'Best score ≥ ${unlockBestScore!}';
    if (unlockGamesPlayed != null) return '${unlockGamesPlayed!} games';
    if (unlockDailyStreak != null) {
      return '${unlockDailyStreak!} daily missions';
    }
    return 'Unlocked';
  }
}
