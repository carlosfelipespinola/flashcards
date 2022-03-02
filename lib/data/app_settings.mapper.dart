import 'dart:convert';
import 'package:flashcards/domain/models/app_settings.dart';

class AppSettingsMapper {

  static final _themeModeStringMapping = {
    AppThemeMode.dark: 'dark',
    AppThemeMode.light: 'light',
    AppThemeMode.system: 'system'
  };

  static Map<String, AppThemeMode> get _stringThemeModeMapping => _themeModeStringMapping.map((key, value) => MapEntry(value, key));

  static AppSettings fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    final standard = AppSettings.standard();
    late final AppThemeMode themeMode;
    if (map.containsKey(_AppSettingsJsonKeys.themeMode)) {
      final rawThemeMode = map[_AppSettingsJsonKeys.themeMode] as String;
      themeMode = _stringThemeModeMapping[rawThemeMode] ?? standard.themeMode;
    } else {
      themeMode = standard.themeMode;
    }
    String? languageCode;
    if (map.containsKey(_AppSettingsJsonKeys.languageCode)) {
      languageCode = map[_AppSettingsJsonKeys.languageCode] as String;
    }
    return AppSettings(
      themeMode: themeMode,
      languageCode: languageCode
    );
  }

  
  static String toJson(AppSettings settings) {
    return jsonEncode({
      _AppSettingsJsonKeys.themeMode: _themeModeStringMapping[settings.themeMode],
      if (settings.languageCode != null) ...{
        _AppSettingsJsonKeys.languageCode: settings.languageCode
      }
    });
  }
}






class _AppSettingsJsonKeys {
  static String themeMode = 'themeMode';
  static String languageCode = 'languageCode';
}