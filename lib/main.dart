import 'package:flashcards/dependencies.dart';
import 'package:flashcards/domain/models/app_settings.dart';
import 'package:flashcards/domain/usecases/load_settings.usecase.dart';
import 'package:flashcards/domain/usecases/save_settings.usecase.dart';
import 'package:flashcards/main.store.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/themes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  final mainStore = await setUpMainStore();
  runApp(MyApp(mainStore, await MyAppLocalizations.findSystemLocaleOrDefault()));
}

Future<MainStore> setUpMainStore() async {
  final loadSettingsUseCase = GetIt.I.get<LoadSettingsUseCase>();
  final saveSettingsUseCase = GetIt.I.get<SaveSettingsUseCase>();
  final settings = await loadSettingsUseCase.call();
  return MainStore(
    MainStoreState(settings: settings),
    saveSettingsUseCase: saveSettingsUseCase
  );
}

class MyApp extends InheritedWidget {
  final MainStore store;
  final SuportedLocale defaultLocale;

  static const _appThemeModeMapping = {
    AppThemeMode.dark: ThemeMode.dark,
    AppThemeMode.light: ThemeMode.light,
    AppThemeMode.system: ThemeMode.system
  };

  MyApp(this.store, this.defaultLocale) : super(
    child: ValueListenableBuilder<MainStoreState>(
      valueListenable: store,
      builder: (context, state, _) {
        return MaterialApp(
          title: 'MyFlashcards',
          debugShowCheckedModeBanner: false,
          theme: generateLightTheme(Colors.indigo),
          darkTheme: generateDarkTheme(Colors.indigo),
          themeMode: _appThemeModeMapping[state.settings.themeMode] ?? ThemeMode.light,
          onGenerateRoute: (settings) => generateRoutes(settings),
          initialRoute: RoutesPaths.flashcards,
          localizationsDelegates: MyAppLocalizations.localizationsDelegates,
          supportedLocales: MyAppLocalizations.supportedLocales,
          locale: MyAppLocalizations.supportedLocales.firstWhere(
            (candidateLocale) => candidateLocale.languageCode == state.settings.languageCode,
            orElse: () => defaultLocale
          ),
        );
      },
    )
  );
  
  static MyApp of(BuildContext context) {
    final MyApp? result = context.dependOnInheritedWidgetOfExactType<MyApp>();
    return result!;
  }

  @override
  bool updateShouldNotify(covariant MyApp oldWidget) => oldWidget.store != store;
}
