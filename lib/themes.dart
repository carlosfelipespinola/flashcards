import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData generateLightTheme(MaterialColor color) {
  final onColor = ThemeData.estimateBrightnessForColor(color).contrastColor;
  return _generateBaseTheme(
      colorScheme: ColorScheme.light(
    primary: color,
    onPrimary: onColor,
    secondary: color,
    onSecondary: onColor,
    background: color[50]!,
  ));
}

ThemeData generateDarkTheme(MaterialColor materialColor) {
  Color color = materialColor.shade300;
  final onColor = ThemeData.estimateBrightnessForColor(color).contrastColor;
  return _generateBaseTheme(
      cursorColor: materialColor.shade300,
      colorScheme: ColorScheme.dark(primary: color, onPrimary: onColor, secondary: color, onSecondary: onColor));
}

ThemeData _generateBaseTheme({required ColorScheme colorScheme, Color? cursorColor}) {
  return ThemeData(
      scaffoldBackgroundColor: colorScheme.background,
      colorScheme: colorScheme,
      textSelectionTheme: TextSelectionThemeData(cursorColor: cursorColor),
      primaryColor: colorScheme.primary,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              primary: colorScheme.primary, onPrimary: colorScheme.onPrimary, minimumSize: Size(40, 40))),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: colorScheme.brightness.inverse,
          statusBarIconBrightness: colorScheme.brightness.inverse,
        ),
        centerTitle: true,
        elevation: 1,
        color: colorScheme.brightness == Brightness.light ? Colors.white : Colors.black,
        iconTheme: IconThemeData(color: colorScheme.brightness == Brightness.light ? Colors.black : Colors.white),
        titleTextStyle: TextStyle(
            color: colorScheme.brightness == Brightness.light ? Colors.black : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        toolbarTextStyle: TextStyle(
            fontSize: 24,
            color: colorScheme.brightness == Brightness.light ? Colors.black : Colors.white,
            fontWeight: FontWeight.w900),
      ),
      cardTheme: CardTheme(
        elevation: 0.6,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()));
}

class ThemeUtils {
  static bool isDarkTheme(ThemeData theme) {
    return theme.brightness == Brightness.dark;
  }
}

extension _BrightnessThemeUtils on Brightness {
  Brightness get inverse {
    if (this == Brightness.dark) return Brightness.light;
    return Brightness.dark;
  }

  Color get contrastColor {
    if (this == Brightness.dark) return Colors.white;
    return Colors.black;
  }
}
