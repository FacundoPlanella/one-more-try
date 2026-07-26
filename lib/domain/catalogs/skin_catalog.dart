import 'package:flutter/material.dart';

import '../entities/skin.dart';

class SkinCatalog {
  SkinCatalog._();

  static const List<SkinDef> all = [
    SkinDef(id: 'default', name: 'Default', color: Color(0xFF5EEAD4)),
    SkinDef(
      id: 'ember',
      name: 'Ember',
      color: Color(0xFFF97316),
      unlockBestScore: 50,
    ),
    SkinDef(
      id: 'moss',
      name: 'Moss',
      color: Color(0xFF86EFAC),
      unlockBestScore: 100,
    ),
    SkinDef(
      id: 'violet',
      name: 'Violet',
      color: Color(0xFFA78BFA),
      unlockBestScore: 200,
    ),
    SkinDef(
      id: 'gold',
      name: 'Gold',
      color: Color(0xFFEAB308),
      unlockBestScore: 350,
    ),
    SkinDef(
      id: 'ghost',
      name: 'Ghost',
      color: Color(0xFFCBD5E1),
      ghost: true,
      unlockBestScore: 500,
    ),
    SkinDef(
      id: 'dual',
      name: 'Dual',
      color: Color(0xFF38BDF8),
      secondary: Color(0xFFF472B6),
      dualTrail: true,
      unlockGamesPlayed: 100,
    ),
    SkinDef(
      id: 'midnight',
      name: 'Midnight',
      color: Color(0xFF0F172A),
      secondary: Color(0xFFE2E8F0),
      unlockDailyStreak: 7,
    ),
    SkinDef(
      id: 'prism',
      name: 'Prism',
      color: Color(0xFF5EEAD4),
      secondary: Color(0xFFF472B6),
      prism: true,
      unlockBestScore: 1000,
    ),
  ];

  static SkinDef byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);

  static bool isUnlocked(SkinDef skin, {
    required int bestScore,
    required int gamesPlayed,
    required int dailyMissionsCompleted,
  }) {
    if (skin.unlockBestScore == null &&
        skin.unlockGamesPlayed == null &&
        skin.unlockDailyStreak == null) {
      return true;
    }
    if (skin.unlockBestScore != null && bestScore >= skin.unlockBestScore!) {
      return true;
    }
    if (skin.unlockGamesPlayed != null &&
        gamesPlayed >= skin.unlockGamesPlayed!) {
      return true;
    }
    if (skin.unlockDailyStreak != null &&
        dailyMissionsCompleted >= skin.unlockDailyStreak!) {
      return true;
    }
    return false;
  }
}
