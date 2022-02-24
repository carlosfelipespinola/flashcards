import 'package:flashcards/data/app_settings.mapper.dart';
import 'package:flashcards/domain/interfaces/app_settings.repository.dart';
import 'package:flashcards/domain/models/app_settings.dart';

import 'database.dart';

class AppSettingsRepository implements IAppSettingsRepository {
  static const settingsKey = 'settings';
  DatabaseProvider databaseProvider;

  AppSettingsRepository({required this.databaseProvider});


  @override
  Future<AppSettings?> load() async {
    final json = await (await databaseProvider.sharedPreferences).load(settingsKey);
    if (json == null) {
      return null;
    }
    return AppSettingsMapper.fromJson(json);
  }

  @override
  Future<void> save(settings) async {
    (await databaseProvider.sharedPreferences)
      .save(settingsKey, AppSettingsMapper.toJson(settings));
  }

}