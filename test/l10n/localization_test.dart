import 'package:flutter_test/flutter_test.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

void main() {
  test('new localization keys have values for all locales', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.settingsTitle, isNotEmpty,
          reason: 'settingsTitle missing for ${locale.languageCode}');
      expect(l10n.themeLabel, isNotEmpty,
          reason: 'themeLabel missing for ${locale.languageCode}');
      expect(l10n.themeSystem, isNotEmpty,
          reason: 'themeSystem missing for ${locale.languageCode}');
      expect(l10n.themeLight, isNotEmpty,
          reason: 'themeLight missing for ${locale.languageCode}');
      expect(l10n.themeDark, isNotEmpty,
          reason: 'themeDark missing for ${locale.languageCode}');
      expect(l10n.languageLabel, isNotEmpty,
          reason: 'languageLabel missing for ${locale.languageCode}');
    }
  });
}
