import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl_standalone.dart' as intl;

class SuportedLocale extends Locale {
  SuportedLocale(String languageCode, {required this.name}) : super(languageCode);

  final String name;
}

class MyAppLocalizations {
  static List<SuportedLocale> get supportedLocales => [
    SuportedLocale('en', name: 'English'),
    SuportedLocale('pt', name: 'Português'),
    SuportedLocale('es', name: 'Español'),
  ];

  static SuportedLocale get defaultLocale => supportedLocales.first;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => AppLocalizations.localizationsDelegates;

  static LocalizationsDelegate<AppLocalizations> get delegate => AppLocalizations.delegate;

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context)!;

  static SuportedLocale suportedLocaleOf(BuildContext context) => Localizations.localeOf(context) as SuportedLocale;

  static Future<SuportedLocale> findSystemLocaleOrDefault() async {
    Locale? locale;
    try {
      var localeStr = await intl.findSystemLocale();
      
      if ( localeStr.contains("_") ) {
        var splittedLocale = localeStr.split("_");
        locale = Locale(splittedLocale[0], splittedLocale[1]);
      } else if (localeStr.contains('-')) {
        var splittedLocale = localeStr.split("-");
        locale = Locale(splittedLocale[0], splittedLocale[1]);
      }
      
    } catch(_) {}
    return supportedLocales.firstWhere(
      (element) => element.languageCode == locale?.languageCode,
      orElse: () => defaultLocale
    );
  }
}