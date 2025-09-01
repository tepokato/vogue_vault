import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeModeKey = 'themeMode';
  static const _localeKey = 'locale';

  late Box _box;
  bool _initialized = false;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  bool get isInitialized => _initialized;

  ThemeMode get themeMode {
    _ensureInitialized();
    return _themeMode;
  }

  Locale? get locale {
    _ensureInitialized();
    return _locale;
  }

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final storedTheme = _box.get(_themeModeKey);
    if (storedTheme is int &&
        storedTheme >= 0 &&
        storedTheme < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[storedTheme];
    }
    final storedLocale = _box.get(_localeKey);
    if (storedLocale is String && storedLocale.isNotEmpty) {
      _locale = Locale(storedLocale);
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

  Future<void> setLocale(Locale? locale) async {
    _ensureInitialized();
    _locale = locale;
    if (locale != null) {
      await _box.put(_localeKey, locale.languageCode);
    } else {
      await _box.delete(_localeKey);
    }
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
