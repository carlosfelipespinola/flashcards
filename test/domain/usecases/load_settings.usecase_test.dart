import 'package:flashcards/data/app_settings.repository.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/models/app_settings.dart';
import 'package:flashcards/domain/usecases/load_settings.usecase.dart';
import 'package:flashcards/domain/usecases/save_settings.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var appSettingsRepository = AppSettingsRepository(databaseProvider: dbProvider);
  var saveSettingsUseCase = SaveSettingsUseCase(appSettingsRepository: appSettingsRepository);
  var loadSettingsUseCase = LoadSettingsUseCase(appSettingsRepository: appSettingsRepository);

  tearDown(() async {
    await database.delete(SharedPreferencesSchema.tableName);
  });

  test('load exiting settings usecase ...', () async {
    final settingsToSave = AppSettings(themeMode: AppThemeMode.dark);
    await saveSettingsUseCase(AppSettings(themeMode: AppThemeMode.dark));
    final loadedSettings = await loadSettingsUseCase();
    expect(loadedSettings.themeMode, settingsToSave.themeMode);
  });

  test('load unexiting settings usecase should return standardSettings ...', () async {
    final loadedSettings = await loadSettingsUseCase();
    expect(loadedSettings.themeMode, AppSettings.standard().themeMode);
  });
}