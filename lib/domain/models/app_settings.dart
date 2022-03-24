enum AppThemeMode { dark, light, system }

class AppSettings {
  AppThemeMode themeMode;
  String? languageCode;

  AppSettings({
    required this.themeMode,
    required this.languageCode
  });

  factory AppSettings.standard() {
    return AppSettings(
      themeMode: AppThemeMode.system,
      languageCode: null
    );
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
