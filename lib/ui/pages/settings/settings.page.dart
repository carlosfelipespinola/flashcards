
import 'package:flashcards/domain/models/app_settings.dart';
import 'package:flashcards/main.dart';
import 'package:flashcards/main.store.dart';
import 'package:flashcards/services/app_info/app_info.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({ Key? key }) : super(key: key);

  final AppInfo _appInfo = GetIt.I<AppInfo>();

  @override
  Widget build(BuildContext context) {
    final store = MyApp.of(context).store;
    return Scaffold(
      appBar: AppBar(title: Text(MyApp.localizationsOf(context).settings),),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            SizedBox(height: 4,),
            ValueListenableBuilder<MainStoreState>(
              valueListenable: store,
              builder: (context, state, _) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.dark_mode),
                    title: Text(MyApp.localizationsOf(context).darkMode),
                    trailing: Switch.adaptive(
                      value: state.settings.themeMode == AppThemeMode.dark,
                      onChanged: (value) {
                        if (value) {
                          store.updateSettings(AppSettings(themeMode: AppThemeMode.dark));
                        } else {
                          store.updateSettings(AppSettings(themeMode: AppThemeMode.light));
                        }
                      },
                    ),
                  ),
                );
              }
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.lock_open),
                title: Text(MyApp.localizationsOf(context).openSourceLicenses),
                onTap: () async => showLicensePage(
                  context: context,
                  applicationIcon: _appInfo.appIconPath != null ? CircleAvatar(child: Image.asset(_appInfo.appIconPath!)) : null,
                  applicationVersion: _appInfo.appVersion
                ),
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