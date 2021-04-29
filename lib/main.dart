import 'package:flashcards/dependencies.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/themes.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // TODO
  // Lesson
  // Lesson Result
  // Permitir remover categoria de um flashcard
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: generateLightTheme(),
      onGenerateRoute: (settings) => generateRoutes(settings),
      initialRoute: RoutesPaths.flashcards
    );
  }
}
