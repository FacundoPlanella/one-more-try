import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/data/save_data.dart';
import 'package:one_more_try/data/save_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveRepository', () {
    test('load() returns a fresh default SaveData when nothing was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SaveRepository(await SharedPreferences.getInstance());

      final data = repo.load();

      expect(data.bestScore, 0);
      expect(data.totalGames, 0);
      expect(data.unlockedSkins, ['default']);
    });

    test('save() then load() round-trips the data through prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = SaveRepository(prefs);

      final data = repo.load();
      data.bestScore = 777;
      data.coins = 55;
      data.medals.add('first_run');
      await repo.save(data);

      // Nuevo repo sobre las mismas prefs simula reabrir la app.
      final reloaded = SaveRepository(prefs).load();
      expect(reloaded.bestScore, 777);
      expect(reloaded.coins, 55);
      expect(reloaded.medals, ['first_run']);
    });

    test('load() falls back to defaults when the stored data is corrupted', () async {
      SharedPreferences.setMockInitialValues({
        'one_more_try_save_v1': 'not valid json{{{',
      });
      final repo = SaveRepository(await SharedPreferences.getInstance());

      final data = repo.load();

      expect(data.bestScore, 0);
      expect(data.unlockedSkins, ['default']);
    });

    test('load() falls back to defaults when the stored value is an empty string', () async {
      SharedPreferences.setMockInitialValues({'one_more_try_save_v1': ''});
      final repo = SaveRepository(await SharedPreferences.getInstance());

      final data = repo.load();

      expect(data.bestScore, 0);
    });

    test('load() migrates a pre-versioned save (version < 1) up to version 1', () async {
      final legacy = SaveData(version: 0, bestScore: 12);
      SharedPreferences.setMockInitialValues({
        'one_more_try_save_v1': legacy.encode(),
      });
      final repo = SaveRepository(await SharedPreferences.getInstance());

      final data = repo.load();

      expect(data.version, 1);
      expect(data.bestScore, 12);
    });
  });
}
