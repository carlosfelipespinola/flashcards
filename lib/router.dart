import 'package:flashcards/ui/pages/categories-manager/categories_manager.page.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.arguments.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.dart';
import 'package:flashcards/ui/pages/flashcards/flashcards.page.dart';
import 'package:flutter/material.dart';

class RoutesPaths {
  static const flashcards = 'flashcards';
  static const flashcardEditor = 'flashcard-editor';
  static const categoryManager = 'category-manager';
}

Route<dynamic> generateRoutes(RouteSettings settings) {
  if ( settings.name == RoutesPaths.flashcards ) {
    return MaterialPageRoute(
      fullscreenDialog: false,
      builder: (context) => FlashcardsPage()
    );
  }
  if ( settings.name == RoutesPaths.flashcardEditor ) {
    late FlashcardEditorPageArguments arguments;
    if (settings.arguments is FlashcardEditorPageArguments) {
      arguments = settings.arguments as FlashcardEditorPageArguments;
    } else {
      arguments = FlashcardEditorPageArguments();
    }
    return MaterialPageRoute(
      fullscreenDialog: false,
      builder: (context) => FlashcardEditorPage(arguments: arguments,)
    ); 
  }
  if ( settings.name == RoutesPaths.categoryManager ) {
    return MaterialPageRoute(
      fullscreenDialog: false,
      builder: (context) => CategoriesManagerPage()
    );
  }
  return MaterialPageRoute(builder: (context) => Scaffold(
    appBar: AppBar(),
    body: Center(child: Text('not implemented yet'),))
  );
}