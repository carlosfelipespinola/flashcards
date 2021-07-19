import 'package:flashcards/dependencies.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/themes.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFlashcards',
      debugShowCheckedModeBanner: false,
      theme: indigoTheme,
      onGenerateRoute: (settings) => generateRoutes(settings),
      initialRoute: RoutesPaths.flashcards
    );
  }
}
