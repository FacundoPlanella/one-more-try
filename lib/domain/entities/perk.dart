/// Efecto pasivo permanente que otorga un [PerkDef] una vez comprado.
enum PerkEffect { biggerMagnet, startWithShield, richerCoins }

/// Mejora permanente comprable una sola vez en la Tienda con monedas.
class PerkDef {
  const PerkDef({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCoins,
    required this.effect,
  });

  final String id;
  final String name;
  final String description;
  final int priceCoins;
  final PerkEffect effect;
}
