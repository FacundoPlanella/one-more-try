import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/data/save_data.dart';

void main() {
  group('SaveData JSON round-trip', () {
    test('encode/decode preserves every field', () {
      final original = SaveData(
        version: 1,
        bestScore: 1234,
        totalGames: 42,
        totalPlayTimeSec: 5678.5,
        totalOrbs: 99,
        coins: 250,
        totalCoinsEarned: 900,
        unlockedSkins: ['default', 'ember', 'shop_diwata'],
        equippedSkin: 'ember',
        purchasedPerks: ['bigger_magnet'],
        medals: ['first_run', 'score_50'],
        titleId: 'cazador',
        deathsPerLane: [3, 5, 2],
        recentScores: [10, 20, 30],
        nearMissCount: 7,
        bestBeatenCount: 4,
        daysPlayedCount: 12,
        lastPlayedDay: '2026-08-01',
        dailyMissionsCompleted: 6,
        dailyDate: '2026-08-02',
        dailyMissionId: 'play_5',
        dailyProgress: 3,
        dailyCompleted: false,
        music: false,
        sfx: true,
        themeMode: 'light',
        languageCode: 'es',
        reduceMotion: true,
        haptics: false,
        tutorialDone: true,
      );

      final decoded = SaveData.decode(original.encode());

      expect(decoded.version, original.version);
      expect(decoded.bestScore, original.bestScore);
      expect(decoded.totalGames, original.totalGames);
      expect(decoded.totalPlayTimeSec, original.totalPlayTimeSec);
      expect(decoded.totalOrbs, original.totalOrbs);
      expect(decoded.coins, original.coins);
      expect(decoded.totalCoinsEarned, original.totalCoinsEarned);
      expect(decoded.unlockedSkins, original.unlockedSkins);
      expect(decoded.equippedSkin, original.equippedSkin);
      expect(decoded.purchasedPerks, original.purchasedPerks);
      expect(decoded.medals, original.medals);
      expect(decoded.titleId, original.titleId);
      expect(decoded.deathsPerLane, original.deathsPerLane);
      expect(decoded.recentScores, original.recentScores);
      expect(decoded.nearMissCount, original.nearMissCount);
      expect(decoded.bestBeatenCount, original.bestBeatenCount);
      expect(decoded.daysPlayedCount, original.daysPlayedCount);
      expect(decoded.lastPlayedDay, original.lastPlayedDay);
      expect(decoded.dailyMissionsCompleted, original.dailyMissionsCompleted);
      expect(decoded.dailyDate, original.dailyDate);
      expect(decoded.dailyMissionId, original.dailyMissionId);
      expect(decoded.dailyProgress, original.dailyProgress);
      expect(decoded.dailyCompleted, original.dailyCompleted);
      expect(decoded.music, original.music);
      expect(decoded.sfx, original.sfx);
      expect(decoded.themeMode, original.themeMode);
      expect(decoded.languageCode, original.languageCode);
      expect(decoded.reduceMotion, original.reduceMotion);
      expect(decoded.haptics, original.haptics);
      expect(decoded.tutorialDone, original.tutorialDone);
    });

    test('fromJson fills sensible defaults for missing fields (forward compat)', () {
      final decoded = SaveData.fromJson(const {});
      expect(decoded.version, 1);
      expect(decoded.bestScore, 0);
      expect(decoded.unlockedSkins, ['default']);
      expect(decoded.equippedSkin, 'default');
      expect(decoded.purchasedPerks, isEmpty);
      expect(decoded.medals, isEmpty);
      expect(decoded.titleId, 'novato');
      expect(decoded.deathsPerLane, [0, 0, 0]);
      expect(decoded.recentScores, isEmpty);
      expect(decoded.music, isTrue);
      expect(decoded.sfx, isTrue);
      expect(decoded.themeMode, 'dark');
      expect(decoded.languageCode, 'en');
      expect(decoded.reduceMotion, isFalse);
      expect(decoded.haptics, isTrue);
      expect(decoded.tutorialDone, isFalse);
    });

    test('fromJson coerces numeric types (e.g. int playtime from an old save)', () {
      final decoded = SaveData.fromJson(const {'totalPlayTimeSec': 120});
      expect(decoded.totalPlayTimeSec, 120.0);
    });
  });

  group('averageScore20', () {
    test('is 0 with no recent scores', () {
      final save = SaveData();
      expect(save.averageScore20, 0);
    });

    test('averages the stored recent scores', () {
      final save = SaveData(recentScores: [10, 20, 30]);
      expect(save.averageScore20, 20);
    });
  });
}
