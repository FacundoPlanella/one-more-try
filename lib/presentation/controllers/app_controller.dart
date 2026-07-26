import 'package:flutter/foundation.dart';

import '../../data/save_data.dart';
import '../../data/save_repository.dart';
import '../../domain/progression/progression_service.dart';
import '../../services/audio_service.dart';
import '../../services/haptics_service.dart';

/// Estado global de progreso / settings. Un solo ChangeNotifier.
class AppController extends ChangeNotifier {
  AppController({
    required this._saveRepository,
    required this.audio,
    required this.haptics,
  });

  final SaveRepository _saveRepository;
  final AudioService audio;
  final HapticsService haptics;
  final ProgressionService progression = ProgressionService();

  late SaveData save;
  bool ready = false;

  Future<void> init() async {
    save = _saveRepository.load();
    progression.ensureDaily(save);
    await audio.applySettings(music: save.music, sfx: save.sfx);
    haptics.enabled = save.haptics;
    ready = true;
    notifyListeners();
    await persist();
  }

  Future<void> persist() => _saveRepository.save(save);

  ProgressionApplyResult finishRun(RunResult run) {
    final result = progression.applyRun(save, run);
    persist();
    notifyListeners();
    return result;
  }

  Future<void> equipSkin(String id) async {
    if (!save.unlockedSkins.contains(id)) return;
    save.equippedSkin = id;
    await persist();
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    save.music = value;
    await audio.applySettings(music: save.music, sfx: save.sfx);
    await persist();
    notifyListeners();
  }

  Future<void> setSfx(bool value) async {
    save.sfx = value;
    await audio.applySettings(music: save.music, sfx: save.sfx);
    await persist();
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    save.themeMode = mode;
    await persist();
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    save.reduceMotion = value;
    await persist();
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    save.haptics = value;
    haptics.enabled = value;
    await persist();
    notifyListeners();
  }

  Future<void> completeTutorial() async {
    save.tutorialDone = true;
    await persist();
    notifyListeners();
  }
}
