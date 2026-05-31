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

  /// Opens the settings box and restores previously chosen theme and locale.
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

  /// Persists the chosen theme by storing the [ThemeMode.index] to keep Hive
  /// payloads small and portable across platforms.
  Future<void> setThemeMode(ThemeMode mode) async {
    _ensureInitialized();
    _themeMode = mode;
    await _box.put(_themeModeKey, mode.index);
    notifyListeners();
  }

  /// Persists the chosen locale using the language code. Passing `null` resets
  /// the preference back to the device default.
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
