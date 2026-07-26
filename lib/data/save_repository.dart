import 'package:shared_preferences/shared_preferences.dart';

import 'save_data.dart';

/// Persistencia local. Sin backend.
class SaveRepository {
  SaveRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'one_more_try_save_v1';

  SaveData load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return SaveData();
    try {
      final data = SaveData.decode(raw);
      return _migrate(data);
    } catch (_) {
      return SaveData();
    }
  }

  Future<void> save(SaveData data) async {
    await _prefs.setString(_key, data.encode());
  }

  /// Migraciones futuras: incrementar [SaveData.version] y transformar aquí.
  SaveData _migrate(SaveData data) {
    if (data.version < 1) data.version = 1;
    return data;
  }
}
