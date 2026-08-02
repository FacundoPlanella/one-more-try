import '../entities/perk.dart';

class PerkCatalog {
  PerkCatalog._();

  static const List<PerkDef> all = [
    PerkDef(
      id: 'bigger_magnet',
      name: 'Bigger magnet',
      description: 'Magnet pickups pull from farther away',
      priceCoins: 8000,
      effect: PerkEffect.biggerMagnet,
    ),
    PerkDef(
      id: 'start_with_shield',
      name: 'Lucky start',
      description: 'Every run starts with a shield already up',
      priceCoins: 16000,
      effect: PerkEffect.startWithShield,
    ),
    PerkDef(
      id: 'richer_coins',
      name: 'Richer coins',
      description: 'Coin pickups are worth 100 extra coins',
      priceCoins: 12000,
      effect: PerkEffect.richerCoins,
    ),
  ];

  static PerkDef byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}
