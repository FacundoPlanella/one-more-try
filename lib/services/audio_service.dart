import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Audio minimalista. Si faltan assets, falla en silencio (el juego sigue).
class AudioService {
  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  bool musicEnabled = true;
  bool sfxEnabled = true;
  bool _assetsReady = false;

  Future<void> init() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.35);
      await _sfx.setVolume(0.7);
      // Verifica que existan los assets; si no, modo silencioso.
      await rootBundle.load('assets/audio/music_loop.wav');
      _assetsReady = true;
    } catch (_) {
      _assetsReady = false;
    }
  }

  Future<void> applySettings({required bool music, required bool sfx}) async {
    musicEnabled = music;
    sfxEnabled = sfx;
    if (!musicEnabled) {
      await _music.stop();
    } else {
      await playMusic();
    }
  }

  Future<void> playMusic() async {
    if (!musicEnabled || !_assetsReady) return;
    try {
      if (_music.state != PlayerState.playing) {
        await _music.play(AssetSource('audio/music_loop.wav'));
      }
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> playTap() => _playSfx('audio/sfx/tap.wav');
  Future<void> playOrb() => _playSfx('audio/sfx/orb.wav');
  Future<void> playDie() => _playSfx('audio/sfx/die.wav');
  Future<void> playBest() => _playSfx('audio/sfx/best.wav');

  final Map<String, DateTime> _lastPlayed = {};
  // Sin esto, una racha de monedas (imán, o varias muy juntas) dispara un
  // play() de plataforma por cada una en el mismo puñado de frames, y eso
  // se siente como una traba — igual no se distinguen sonidos más
  // seguidos que esto.
  static const _sfxCooldown = Duration(milliseconds: 45);

  Future<void> _playSfx(String path) async {
    if (!sfxEnabled || !_assetsReady) return;
    final now = DateTime.now();
    final last = _lastPlayed[path];
    if (last != null && now.difference(last) < _sfxCooldown) return;
    _lastPlayed[path] = now;
    try {
      await _sfx.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _music.dispose();
    await _sfx.dispose();
  }
}
