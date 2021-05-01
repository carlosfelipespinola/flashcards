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
  // Não permitir selecionar um número maior que o possível em generate lesson
  // Redirecionar para Lesson após generate Lesson
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
