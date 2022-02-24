import 'package:flashcards/data/app_settings.repository.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/models/app_settings.dart';
import 'package:flashcards/domain/usecases/load_settings.usecase.dart';
import 'package:flashcards/domain/usecases/save_settings.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var dbProvider = DatabaseProvider(test: true);
  var appSettingsRepository = AppSettingsRepository(databaseProvider: dbProvider);
  var saveSettingsUseCase = SaveSettingsUseCase(appSettingsRepository: appSettingsRepository);
  var loadSettingsUseCase = LoadSettingsUseCase(appSettingsRepository: appSettingsRepository);

  test('save settings usecase ...', () async {
    final settingsToSave = AppSettings(themeMode: AppThemeMode.dark);
    await saveSettingsUseCase(AppSettings(themeMode: AppThemeMode.dark));
    final loadedSettings = await loadSettingsUseCase();
    expect(loadedSettings.themeMode, settingsToSave.themeMode);
  });
}