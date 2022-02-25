import 'package:flashcards/main.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/ui/pages/flashcard-search/flashcard_search.dart';
import 'package:flashcards/ui/pages/lesson/lesson.page.arguments.dart';
import 'package:flashcards/ui/widgets/flashcards_grid.dart';
import 'package:flashcards/ui/widgets/lesson_generator_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../router.dart';

class FlashcardsPage extends StatefulWidget {
  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {

  GlobalKey<FlashcardsGridState> _flashcardsGridKey = GlobalKey();


  bool shouldHideFloatingActionButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FlashcardsGrid(
          key: _flashcardsGridKey,
          onScrollBottomEnter: () => setState(() { shouldHideFloatingActionButton = true; }),
          onScrollBottomExit: () => setState(() { shouldHideFloatingActionButton = false; }),
        )
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: !shouldHideFloatingActionButton,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
        overlayColor: Colors.black,
        children: [
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.add),
            onTap: () async {
              await Navigator.of(context).pushNamed(RoutesPaths.flashcardEditor);
              _flashcardsGridKey.currentState?.fetchFlashcards();
            },
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                MyApp.localizationsOf(context).createFlashcard.toUpperCase(),
                style: speedDialChildTextStyle
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.play_arrow),
            onTap: showLessonGeneratorForm,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                MyApp.localizationsOf(context).practice.toUpperCase(),
                style: speedDialChildTextStyle
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.label),
            onTap: () async {
              await Navigator.of(context).pushNamed(RoutesPaths.categoryManager);
              _flashcardsGridKey.currentState?.fetchFlashcards();
            },
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                MyApp.localizationsOf(context).manageCategories.toUpperCase(),
                style: speedDialChildTextStyle
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.search),
            onTap: () async {
              await showSearch(context: context, delegate: FlashcardSearch());
              _flashcardsGridKey.currentState?.fetchFlashcards();
            },
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                MyApp.localizationsOf(context).searchFlashcard.toUpperCase(),
                style: speedDialChildTextStyle
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.settings),
            onTap: () => Navigator.of(context).pushNamed(RoutesPaths.settings),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                MyApp.localizationsOf(context).settings.toUpperCase(),
                style: speedDialChildTextStyle
              ),
            )
          ),
        ],
      ),
    );
  }

  TextStyle get speedDialChildTextStyle => TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

  void showLessonGeneratorForm() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: LessonGeneratorForm(
            onGenerate: (flashcards) async {
              if (ModalRoute.of(context)!.isCurrent) {
                Navigator.of(context).pop();
                await Navigator.of(context).pushNamed(RoutesPaths.lesson, arguments: LessonPageArguments(flashcards));
                _flashcardsGridKey.currentState?.fetchFlashcards();
              }
            },
          ),
        );
      }
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}