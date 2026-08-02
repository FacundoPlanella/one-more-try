import 'package:flutter/material.dart';

import '../entities/skin.dart';

class SkinCatalog {
  SkinCatalog._();

  static const String _players = 'assets/images/creatures/players';

  static const List<SkinDef> all = [
    SkinDef(
      id: 'default',
      name: 'Santelmo',
      creatureName: 'Santelmo (Wisp)',
      color: Color(0xFFFBBF24),
      spriteAsset: '$_players/default.png',
    ),
    SkinDef(
      id: 'ember',
      name: 'Kapre',
      creatureName: 'Kapre (Tree Demon)',
      color: Color(0xFFF97316),
      spriteAsset: '$_players/ember.png',
      unlockBestScore: 50,
    ),
    SkinDef(
      id: 'moss',
      name: 'Taong-Tuod',
      creatureName: 'Taong-Tuod (Treant)',
      color: Color(0xFF86EFAC),
      spriteAsset: '$_players/moss.png',
      unlockBestScore: 100,
    ),
    SkinDef(
      id: 'violet',
      name: 'Sirena',
      creatureName: 'Sirena (Mermaid)',
      color: Color(0xFFA78BFA),
      spriteAsset: '$_players/violet.png',
      unlockBestScore: 200,
    ),
    SkinDef(
      id: 'gold',
      name: 'Dwende',
      creatureName: 'Dwende (Mushroom)',
      color: Color(0xFFEAB308),
      spriteAsset: '$_players/gold.png',
      unlockBestScore: 350,
    ),
    SkinDef(
      id: 'ghost',
      name: 'Ek-ek',
      creatureName: 'Ek-ek (Harpy)',
      color: Color(0xFFCBD5E1),
      ghost: true,
      spriteAsset: '$_players/ghost.png',
      unlockBestScore: 500,
    ),
    SkinDef(
      id: 'dual',
      name: 'Blue Dwende',
      creatureName: 'Dwende (Blue)',
      color: Color(0xFF38BDF8),
      secondary: Color(0xFFF472B6),
      dualTrail: true,
      spriteAsset: '$_players/dual.png',
      unlockGamesPlayed: 100,
    ),
    SkinDef(
      id: 'midnight',
      name: 'Tikbalang',
      creatureName: 'Tikbalang',
      color: Color(0xFF0F172A),
      secondary: Color(0xFFE2E8F0),
      spriteAsset: '$_players/midnight.png',
      unlockDailyStreak: 7,
    ),
    SkinDef(
      id: 'prism',
      name: 'Aghoy',
      creatureName: 'Aghoy (Fairy)',
      color: Color(0xFF5EEAD4),
      secondary: Color(0xFFF472B6),
      prism: true,
      spriteAsset: '$_players/prism.png',
      unlockBestScore: 1000,
    ),
    // Exclusivas de Tienda: se compran con monedas, no por progreso.
    SkinDef(
      id: 'shop_diwata',
      name: 'Diwata',
      creatureName: 'Diwata (Nature spirit)',
      color: Color(0xFF4ADE80),
      spriteAsset: '$_players/shop_diwata.png',
      priceCoins: 8000,
    ),
    SkinDef(
      id: 'shop_tiyanak',
      name: 'Tiyanak',
      creatureName: 'Tiyanak (Vampiric infant)',
      color: Color(0xFFA855F7),
      spriteAsset: '$_players/shop_tiyanak.png',
      priceCoins: 13000,
    ),
    SkinDef(
      id: 'shop_sigbin',
      name: 'Sigbin',
      creatureName: 'Sigbin (Shadow beast)',
      color: Color(0xFF92400E),
      secondary: Color(0xFF44403C),
      spriteAsset: '$_players/shop_sigbin.png',
      priceCoins: 18000,
    ),
    SkinDef(
      id: 'shop_kataw',
      name: 'Kataw',
      creatureName: 'Kataw (Merman)',
      color: Color(0xFF0284C7),
      spriteAsset: '$_players/shop_kataw.png',
      priceCoins: 23000,
    ),
    SkinDef(
      id: 'shop_engkanto',
      name: 'Engkanto',
      creatureName: 'Engkanto (Enchanted being)',
      color: Color(0xFFF9A8D4),
      spriteAsset: '$_players/shop_engkanto.png',
      priceCoins: 28000,
    ),
    SkinDef(
      id: 'shop_manananggal',
      name: 'Manananggal',
      creatureName: 'Manananggal',
      color: Color(0xFFEF4444),
      secondary: Color(0xFF1F2937),
      spriteAsset: '$_players/shop_manananggal.png',
      priceCoins: 33000,
    ),
    SkinDef(
      id: 'shop_amalanhig',
      name: 'Amalanhig',
      creatureName: 'Amalanhig (Walking dead)',
      color: Color(0xFFFBBF24),
      secondary: Color(0xFFDC2626),
      spriteAsset: '$_players/shop_amalanhig.png',
      priceCoins: 40000,
    ),
    SkinDef(
      id: 'shop_bakunawa',
      name: 'Bakunawa',
      creatureName: 'Bakunawa (Moon serpent)',
      color: Color(0xFF0EA5E9),
      secondary: Color(0xFFFACC15),
      prism: true,
      spriteAsset: '$_players/shop_bakunawa.png',
      priceCoins: 48000,
    ),
  ];

  static SkinDef byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);

  static bool isUnlocked(SkinDef skin, {
    required int bestScore,
    required int gamesPlayed,
    required int dailyMissionsCompleted,
  }) {
    // Las skins de Tienda solo se desbloquean comprándolas, nunca por progreso.
    if (skin.isShopExclusive) return false;
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
