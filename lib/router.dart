import 'package:flashcards/ui/pages/flashcards/flashcards.page.dart';
import 'package:flutter/material.dart';

class RoutesPaths {
  static const flashcards = 'flashcards';
}

Route<dynamic> generateRoutes(RouteSettings settings) {
  if ( settings.name == RoutesPaths.flashcards ) {
    return MaterialPageRoute(
      fullscreenDialog: false,
      builder: (context) => FlashcardsPage()
    );
  }
  return MaterialPageRoute(builder: (context) => Scaffold(
    appBar: AppBar(),
    body: Center(child: Text('not implemented yet'),))
  );
}