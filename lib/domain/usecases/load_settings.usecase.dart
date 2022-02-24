

import 'package:flashcards/domain/interfaces/app_settings.repository.dart';
import 'package:flashcards/domain/models/app_settings.dart';

class LoadSettingsUseCase {

  final IAppSettingsRepository _appSettingsRepository;
  LoadSettingsUseCase({
    required IAppSettingsRepository appSettingsRepository,
  }) : _appSettingsRepository = appSettingsRepository;

  Future<AppSettings> call() async {
    try {
      return (await _appSettingsRepository.load()) ?? AppSettings.standard();
    } catch (_) {
      return AppSettings.standard();
    }
  }

}
