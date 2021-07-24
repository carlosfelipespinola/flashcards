
import 'package:flutter/material.dart';

ThemeData get indigoTheme => generateLightTheme(Colors.indigo);

ThemeData get greenTheme => generateLightTheme(Colors.green);

ThemeData generateLightTheme(MaterialColor color) {
  final primaryColor = color[400];
  final backgroundColor = color[50];
  return ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      color: Colors.white,
      elevation: 1,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.w900
        )
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.black
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
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: primaryColor)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primaryColor),
    buttonColor: primaryColor,
    primarySwatch: color,
    primaryColor: primaryColor,
    accentColor: color
  );
}