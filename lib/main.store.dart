

import 'package:flashcards/domain/usecases/save_settings.usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flashcards/domain/models/app_settings.dart';

class MainStoreState {
  AppSettings settings;

  MainStoreState({
    required this.settings,
  });

  MainStoreState copyWith({
    AppSettings? settings,
  }) {
    return MainStoreState(
      settings: settings ?? this.settings,
    );
  }
}

class MainStore extends ValueNotifier<MainStoreState> {
  final SaveSettingsUseCase saveSettingsUseCase;

  MainStore(MainStoreState state, {required this.saveSettingsUseCase}) : super(state);

  void updateSettings(AppSettings settings) {
    this.value = value.copyWith(settings: settings);
    saveSettingsUseCase.call(settings);
  }
}
