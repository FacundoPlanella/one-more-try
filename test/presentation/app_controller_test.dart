import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/data/save_repository.dart';
import 'package:one_more_try/domain/progression/progression_service.dart';
import 'package:one_more_try/presentation/controllers/app_controller.dart';
import 'package:one_more_try/services/audio_service.dart';
import 'package:one_more_try/services/haptics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// audioplayers habla con el motor nativo por estos dos MethodChannel. En
/// tests no hay plugin registrado, así que los interceptamos para que
/// `AudioPlayer()` no lance MissingPluginException al construirse.
void _stubAudioPlayersChannels() {
  const channels = [
    MethodChannel('xyz.luan/audioplayers'),
    MethodChannel('xyz.luan/audioplayers.global'),
  ];
  for (final channel in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
  }
}

/// Evita tocar los platform channels de audioplayers durante los tests.
class FakeAudioService extends AudioService {
  int applySettingsCalls = 0;

  @override
  Future<void> applySettings({required bool music, required bool sfx}) async {
    applySettingsCalls++;
    musicEnabled = music;
    sfxEnabled = sfx;
  }
}

RunResult _run({int score = 10}) => RunResult(
      score: score,
      durationSec: 5,
      orbsCollected: 0,
      coinsCollected: 0,
      deathLane: -1,
      collectedAnyOrb: false,
    );

Future<AppController> _buildController({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final repo = SaveRepository(await SharedPreferences.getInstance());
  final controller = AppController(
    saveRepository: repo,
    audio: FakeAudioService(),
    haptics: HapticsService(),
  );
  await controller.init();
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_stubAudioPlayersChannels);

  group('AppController.init', () {
    test('loads defaults, marks ready and assigns a daily mission', () async {
      final controller = await _buildController();
      expect(controller.ready, isTrue);
      expect(controller.save.bestScore, 0);
      expect(controller.save.dailyMissionId, isNotEmpty);
    });

    test('persists the save right after init (survives a reload)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = AppController(
        saveRepository: SaveRepository(prefs),
        audio: FakeAudioService(),
        haptics: HapticsService(),
      );
      await controller.init();

      final reloaded = SaveRepository(prefs).load();
      expect(reloaded.dailyMissionId, controller.save.dailyMissionId);
    });
  });

  group('purchaseSkin', () {
    test('fails when the skin is not shop-exclusive', () async {
      final controller = await _buildController();
      final ok = await controller.purchaseSkin('ember');
      expect(ok, isFalse);
      expect(controller.save.unlockedSkins, isNot(contains('ember')));
    });

    test('fails when coins are insufficient', () async {
      final controller = await _buildController();
      controller.save.coins = 10; // shop_diwata cuesta 8000
      final ok = await controller.purchaseSkin('shop_diwata');
      expect(ok, isFalse);
      expect(controller.save.coins, 10);
      expect(controller.save.unlockedSkins, isNot(contains('shop_diwata')));
    });

    test('succeeds, deducts coins, unlocks the skin and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = AppController(
        saveRepository: SaveRepository(prefs),
        audio: FakeAudioService(),
        haptics: HapticsService(),
      );
      await controller.init();
      controller.save.coins = 10000;

      final ok = await controller.purchaseSkin('shop_diwata');

      expect(ok, isTrue);
      expect(controller.save.coins, 2000);
      expect(controller.save.unlockedSkins, contains('shop_diwata'));

      final reloaded = SaveRepository(prefs).load();
      expect(reloaded.coins, 2000);
      expect(reloaded.unlockedSkins, contains('shop_diwata'));
    });

    test('fails on a second purchase of an already-owned skin', () async {
      final controller = await _buildController();
      controller.save.coins = 20000;
      expect(await controller.purchaseSkin('shop_diwata'), isTrue);
      final coinsAfterFirst = controller.save.coins;

      final ok = await controller.purchaseSkin('shop_diwata');

      expect(ok, isFalse);
      expect(controller.save.coins, coinsAfterFirst);
    });
  });

  group('purchasePerk', () {
    test('fails when coins are insufficient', () async {
      final controller = await _buildController();
      controller.save.coins = 5; // bigger_magnet cuesta 8000
      final ok = await controller.purchasePerk('bigger_magnet');
      expect(ok, isFalse);
      expect(controller.save.purchasedPerks, isEmpty);
    });

    test('succeeds and deducts the perk price exactly once', () async {
      final controller = await _buildController();
      controller.save.coins = 20000;

      final ok = await controller.purchasePerk('bigger_magnet');
      expect(ok, isTrue);
      expect(controller.save.coins, 12000);
      expect(controller.save.purchasedPerks, ['bigger_magnet']);

      final again = await controller.purchasePerk('bigger_magnet');
      expect(again, isFalse);
      expect(controller.save.coins, 12000);
    });
  });

  group('equipSkin', () {
    test('does nothing if the skin has not been unlocked', () async {
      final controller = await _buildController();
      await controller.equipSkin('ember');
      expect(controller.save.equippedSkin, 'default');
    });

    test('equips an unlocked skin', () async {
      final controller = await _buildController();
      controller.save.unlockedSkins.add('ember');
      await controller.equipSkin('ember');
      expect(controller.save.equippedSkin, 'ember');
    });
  });

  group('finishRun', () {
    test('applies progression, persists and notifies listeners', () async {
      final controller = await _buildController();
      var notified = 0;
      controller.addListener(() => notified++);

      final result = controller.finishRun(_run(score: 60));

      expect(result.newBest, isTrue);
      expect(controller.save.bestScore, 60);
      expect(notified, greaterThan(0));
    });
  });

  group('settings setters', () {
    test('setMusic updates save and forwards to the audio service', () async {
      final controller = await _buildController();
      final fakeAudio = controller.audio as FakeAudioService;
      final before = fakeAudio.applySettingsCalls;

      await controller.setMusic(false);

      expect(controller.save.music, isFalse);
      expect(fakeAudio.applySettingsCalls, greaterThan(before));
    });

    test('setHaptics updates both save and the haptics service', () async {
      final controller = await _buildController();
      await controller.setHaptics(false);
      expect(controller.save.haptics, isFalse);
      expect(controller.haptics.enabled, isFalse);
    });

    test('setThemeMode, setLanguageCode and setReduceMotion persist their values', () async {
      final controller = await _buildController();
      await controller.setThemeMode('light');
      await controller.setLanguageCode('es');
      await controller.setReduceMotion(true);

      expect(controller.save.themeMode, 'light');
      expect(controller.save.languageCode, 'es');
      expect(controller.save.reduceMotion, isTrue);
    });

    test('completeTutorial marks the save as tutorialDone', () async {
      final controller = await _buildController();
      expect(controller.save.tutorialDone, isFalse);
      await controller.completeTutorial();
      expect(controller.save.tutorialDone, isTrue);
    });
  });
}
