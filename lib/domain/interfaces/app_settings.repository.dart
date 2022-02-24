
import 'package:flashcards/domain/models/app_settings.dart';

abstract class IAppSettingsRepository {

  Future<void> save(AppSettings settings);

  Future<AppSettings?> load();
}