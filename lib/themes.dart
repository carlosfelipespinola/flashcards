
import 'package:flutter/material.dart';

ThemeData generateLightTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.blueGrey[50],
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      color: Colors.blueGrey[50],
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
    primarySwatch: Colors.blueGrey,
  );
}