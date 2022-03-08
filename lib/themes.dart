
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


ThemeData generateLightTheme(MaterialColor color) {
  return _generateBaseTheme(
    colorScheme: ColorScheme.light(
      primary: color,
      secondary: color,
      background: color[50]!,
    )
  );
}

ThemeData generateDarkTheme(MaterialColor color) {
  return _generateBaseTheme(
    colorScheme: ColorScheme.dark(
      primary: color,
      secondary: color,
    )
  );
}

ThemeData _generateBaseTheme({
  required ColorScheme colorScheme,
}) {
  return ThemeData(
    scaffoldBackgroundColor: colorScheme.background,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    primaryColorBrightness: ThemeData.estimateBrightnessForColor(colorScheme.primary),
    accentColor: colorScheme.secondary,
    accentColorBrightness: ThemeData.estimateBrightnessForColor(colorScheme.secondary),
    buttonColor: colorScheme.primary,
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      primary: colorScheme.primary,
      onPrimary: ThemeData.estimateBrightnessForColor(colorScheme.primary) == Brightness.dark ? Colors.white : Colors.black,
      minimumSize: Size(40, 40)
    )),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colorScheme.primary, foregroundColor: Colors.white),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: colorScheme.brightness,
        statusBarIconBrightness: colorScheme.brightness,
      ),
      centerTitle: true,
      elevation: 1,
      brightness: colorScheme.brightness,
      color: colorScheme.brightness == Brightness.light ? Colors.white : Colors.black,
      iconTheme: IconThemeData(color: colorScheme.brightness == Brightness.light ? Colors.black : Colors.white),
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 24,
          color: colorScheme.brightness == Brightness.light ? Colors.black : null,
          fontWeight: FontWeight.w900
        )
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0.6,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder()
    )
  );
}

class ThemeUtils {
  static bool isDarkTheme(ThemeData theme) {
    return theme.brightness == Brightness.dark;
  }
}
