

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
  MainStore(MainStoreState state) : super(state);


  void updateSettings(AppSettings settings) {
    this.value = value.copyWith(settings: settings);
  }
}
