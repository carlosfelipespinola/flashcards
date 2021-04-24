import 'package:flashcards/router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey[50],
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          color: Colors.blueGrey[50],
          textTheme: TextTheme(
            headline6: TextStyle(
              fontSize: 24,
              color: Colors.black,
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
        primarySwatch: Colors.blueGrey,
      ),
      onGenerateRoute: (settings) => generateRoutes(settings),
      initialRoute: RoutesPaths.flashcards
    );
  }
}
