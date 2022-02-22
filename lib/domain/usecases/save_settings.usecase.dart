

import 'package:flashcards/domain/interfaces/app_settings.repository.dart';
import 'package:flashcards/domain/models/app_settings.dart';

class SaveSettingsUseCase {

  final IAppSettingsRepository _appSettingsRepository;
  SaveSettingsUseCase({
    required IAppSettingsRepository appSettingsRepository,
  }) : _appSettingsRepository = appSettingsRepository;

  Future<void> call(AppSettings appSettings) async {
    await _appSettingsRepository.save(appSettings);
  }

}
