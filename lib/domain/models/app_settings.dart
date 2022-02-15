
enum AppThemeMode { dark, light, system }

class AppSettings {
  AppThemeMode themeMode;

  AppSettings({
    required this.themeMode,
  });

  factory AppSettings.standard() {
    return AppSettings(themeMode: AppThemeMode.light);
  }
}
