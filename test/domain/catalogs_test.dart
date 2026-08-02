import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/domain/catalogs/perk_catalog.dart';
import 'package:one_more_try/domain/catalogs/progression_catalogs.dart';
import 'package:one_more_try/domain/catalogs/skin_catalog.dart';

void main() {
  group('MissionCatalog.forDate', () {
    test('is deterministic for the same date', () {
      final date = DateTime(2026, 3, 15);
      final a = MissionCatalog.forDate(date);
      final b = MissionCatalog.forDate(date);
      expect(a.id, b.id);
    });

    test('cycles through the pool via the documented key formula', () {
      for (final date in [
        DateTime(2026, 1, 1),
        DateTime(2026, 6, 30),
        DateTime(2027, 12, 31),
      ]) {
        final key = date.year * 10000 + date.month * 100 + date.day;
        final expected = MissionCatalog.pool[key % MissionCatalog.pool.length];
        expect(MissionCatalog.forDate(date).id, expected.id);
      }
    });

    test('always returns a mission that exists in the pool', () {
      for (var day = 1; day <= 28; day++) {
        final mission = MissionCatalog.forDate(DateTime(2026, 2, day));
        expect(MissionCatalog.pool.map((m) => m.id), contains(mission.id));
      }
    });
  });

  group('MedalCatalog', () {
    test('has no duplicate ids', () {
      final ids = MedalCatalog.all.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('TitleCatalog', () {
    test('has no duplicate ids and includes the default novato title', () {
      final ids = TitleCatalog.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('novato'));
    });
  });

  group('SkinCatalog', () {
    test('has no duplicate ids', () {
      final ids = SkinCatalog.all.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('default skin has no gating and is always unlocked', () {
      final skin = SkinCatalog.byId('default');
      expect(
        SkinCatalog.isUnlocked(
          skin,
          bestScore: 0,
          gamesPlayed: 0,
          dailyMissionsCompleted: 0,
        ),
        isTrue,
      );
    });

    test('byId falls back to the first skin for an unknown id', () {
      expect(SkinCatalog.byId('does_not_exist').id, SkinCatalog.all.first.id);
    });

    test('shop-exclusive skins are never unlocked by progress, even at max stats', () {
      for (final skin in SkinCatalog.all.where((s) => s.isShopExclusive)) {
        expect(
          SkinCatalog.isUnlocked(
            skin,
            bestScore: 1 << 30,
            gamesPlayed: 1 << 30,
            dailyMissionsCompleted: 1 << 30,
          ),
          isFalse,
          reason: '${skin.id} should only unlock via purchase',
        );
        expect(skin.priceCoins, greaterThan(0));
      }
    });

    test('gamesPlayed-gated skin unlocks exactly at its threshold', () {
      final skin = SkinCatalog.byId('dual');
      expect(skin.unlockGamesPlayed, 100);
      expect(
        SkinCatalog.isUnlocked(
          skin,
          bestScore: 0,
          gamesPlayed: 99,
          dailyMissionsCompleted: 0,
        ),
        isFalse,
      );
      expect(
        SkinCatalog.isUnlocked(
          skin,
          bestScore: 0,
          gamesPlayed: 100,
          dailyMissionsCompleted: 0,
        ),
        isTrue,
      );
    });
  });

  group('PerkCatalog', () {
    test('has no duplicate ids', () {
      final ids = PerkCatalog.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every perk has a positive coin price', () {
      for (final perk in PerkCatalog.all) {
        expect(perk.priceCoins, greaterThan(0));
      }
    });

    test('byId returns the matching perk', () {
      final perk = PerkCatalog.byId('richer_coins');
      expect(perk.id, 'richer_coins');
    });

    test('byId falls back to the first perk for an unknown id', () {
      expect(PerkCatalog.byId('nope').id, PerkCatalog.all.first.id);
    });
  });
}
