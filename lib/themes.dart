
import 'package:flutter/material.dart';

ThemeData generateLightTheme() {
  final primaryColor = Colors.indigo[400];
  final backgroundColor = Colors.indigo[50];
  return ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      color: backgroundColor,
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
    primarySwatch: Colors.indigo,
    primaryColor: primaryColor
  );
}