import 'package:flashcards/domain/models/app_settings.dart';
import 'package:flashcards/main.dart';
import 'package:flashcards/main.store.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/services/app_info/app_info.dart';
import 'package:flashcards/themes.dart';
import 'package:flashcards/ui/widgets/flashcards_export_dialog.dart';
import 'package:flashcards/ui/widgets/flashcards_import_dialog.dart';
import 'package:flashcards/ui/widgets/language_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final AppInfo _appInfo = GetIt.I<AppInfo>();

  @override
  Widget build(BuildContext context) {
    final store = MyApp.of(context).store;
    return Scaffold(
      appBar: AppBar(
        title: Text(MyAppLocalizations.of(context).settings),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            SizedBox(
              height: 4,
            ),
            ValueListenableBuilder<MainStoreState>(
                valueListenable: store,
                builder: (context, state, _) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.dark_mode),
                      title: Text(MyAppLocalizations.of(context).darkMode),
                      trailing: Switch.adaptive(
                        value: ThemeUtils.isDarkTheme(Theme.of(context)),
                        onChanged: (isDark) {
                          if (isDark) {
                            store.updateSettings(store.value.settings.copyWith(themeMode: AppThemeMode.dark));
                          } else {
                            store.updateSettings(store.value.settings.copyWith(themeMode: AppThemeMode.light));
                          }
                        },
                      ),
                    ),
                  );
                }),
            ValueListenableBuilder<MainStoreState>(
                valueListenable: store,
                builder: (context, state, _) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.translate),
                      title: Text(MyAppLocalizations.suportedLocaleOf(context).name),
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () {
                        showModalBottomSheet(context: context, builder: (context) => LanguagePickerDialog());
                      },
                    ),
                  );
                }),
            Card(
              child: ListTile(
                leading: Icon(Icons.lock_open),
                title: Text(MyAppLocalizations.of(context).openSourceLicenses),
                onTap: () async => showLicensePage(
                    context: context,
                    applicationIcon:
                        _appInfo.appIconPath != null ? CircleAvatar(child: Image.asset(_appInfo.appIconPath!)) : null,
                    applicationVersion: _appInfo.appVersion),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text(MyAppLocalizations.of(context).importFlashcardsTitle),
                onTap: () async => showDialog(context: context, builder: (context) => FlashcardsImportDialog()),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.upload),
                title: Text(MyAppLocalizations.of(context).exportFlashcardsTitle),
                onTap: () async => showDialog(context: context, builder: (context) => FlashcardsExportDialog()),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
