import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeModeKey = 'themeMode';

  late Box _box;
  bool _initialized = false;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isInitialized => _initialized;

  ThemeMode get themeMode {
    _ensureInitialized();
    return _themeMode;
  }

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box.get(_themeModeKey);
    if (stored is int && stored >= 0 && stored < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[stored];
    }
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('SettingsService has not been initialized.');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _ensureInitialized();
    _themeMode = mode;
    await _box.put(_themeModeKey, mode.index);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_initialized) {
      _box.close();
    }
    super.dispose();
  }
}
