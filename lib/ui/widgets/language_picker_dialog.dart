

import 'package:flashcards/main.dart';
import 'package:flashcards/main.store.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flutter/material.dart';

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = MyApp.of(context).store;
    return ValueListenableBuilder<MainStoreState>(
      valueListenable: store,
      builder: (context, state, snapshot) {
        final locales = MyAppLocalizations.supportedLocales.toList();
        locales.sort((a, b) => a.name.compareTo(b.name));
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 1,),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: locales.length,
          itemBuilder: (context, index) {
            final locale = locales.elementAt(index);
            return ListTile(
              minVerticalPadding: 4,
              title: Text(locale.name),
              trailing: locale.languageCode == MyAppLocalizations.suportedLocaleOf(context).languageCode ? Icon(Icons.check) : null,
              onTap: () {
                store.updateSettings(store.value.settings.copyWith(languageCode: locale.languageCode));
              },
            );
          }
        );
      }
    );
  }
}