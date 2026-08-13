import 'package:flutter/services.dart';

class HapticsService {
  bool enabled = true;

  DateTime? _lastLight;
  // Sin esto, una racha de monedas atraídas por el imán (o varias juntas)
  // dispara un llamado de plataforma por cada una en el mismo puñado de
  // frames, lo que se siente como una traba — el usuario igual no puede
  // distinguir pulsos más seguidos que esto.
  static const _lightCooldown = Duration(milliseconds: 45);

  Future<void> light() async {
    if (!enabled) return;
    final now = DateTime.now();
    if (_lastLight != null && now.difference(_lastLight!) < _lightCooldown) {
      return;
    }
    _lastLight = now;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }
}
