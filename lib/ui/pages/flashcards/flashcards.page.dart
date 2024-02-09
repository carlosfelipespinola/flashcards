import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/ui/pages/flashcard-search/flashcard_search.dart';
import 'package:flashcards/ui/pages/flashcards-of-category/flashcards_of_category.page.dart';
import 'package:flashcards/ui/pages/lesson/lesson.page.arguments.dart';
import 'package:flashcards/ui/widgets/bottom_sheet_dialog.dart';
import 'package:flashcards/ui/widgets/flashcards_grid.dart';
import 'package:flashcards/ui/widgets/handle.dart';
import 'package:flashcards/ui/widgets/lesson_generator_form.dart';
import 'package:flashcards/ui/widgets/shared_flashcards_importer_widget.dart';
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
    return SharedFlashcardsImporterWidget(
      beforeShowImportDialog: () => Navigator.popUntil(context, ModalRoute.withName(RoutesPaths.flashcards)),
      onFlashcardsImported: () {
        if (mounted) {
          _flashcardsGridKey.currentState?.fetchFlashcards();
        }
      },
      child: Scaffold(
        body: SafeArea(
            child: FlashcardsGrid(
          key: _flashcardsGridKey,
          showAllOfCategoryTap: (category) async {
            await Navigator.of(context).pushNamed(RoutesPaths.flashcardsOfCategory,
                arguments: FlashcardsOfCategoryPageArguments(category: category));
            _flashcardsGridKey.currentState?.fetchFlashcards();
          },
          onScrollBottomEnter: () => setState(() {
            shouldHideFloatingActionButton = true;
          }),
          onScrollBottomExit: () => setState(() {
            shouldHideFloatingActionButton = false;
          }),
          numberOfRowsPerCategory: 2,
        )),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          visible: !shouldHideFloatingActionButton,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                labelWidget: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(MyAppLocalizations.of(context).createFlashcard.toUpperCase(),
                      style: speedDialChildTextStyle),
                )),
            SpeedDialChild(
                elevation: 2,
                child: Icon(Icons.play_arrow),
                onTap: () => showLessonGeneratorForm(context),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                labelWidget: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(MyAppLocalizations.of(context).practice.toUpperCase(), style: speedDialChildTextStyle),
                )),
            SpeedDialChild(
                elevation: 2,
                child: Icon(Icons.label),
                onTap: () async {
                  await Navigator.of(context).pushNamed(RoutesPaths.categoryManager);
                  _flashcardsGridKey.currentState?.fetchFlashcards();
                },
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                labelWidget: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(MyAppLocalizations.of(context).manageCategories.toUpperCase(),
                      style: speedDialChildTextStyle),
                )),
            SpeedDialChild(
                elevation: 2,
                child: Icon(Icons.search),
                onTap: () async {
                  await showSearch(context: context, delegate: FlashcardSearch());
                  _flashcardsGridKey.currentState?.fetchFlashcards();
                },
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                labelWidget: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(MyAppLocalizations.of(context).searchFlashcard.toUpperCase(),
                      style: speedDialChildTextStyle),
                )),
            SpeedDialChild(
                elevation: 2,
                child: Icon(Icons.settings),
                onTap: () async {
                  await Navigator.of(context).pushNamed(RoutesPaths.settings);
                  _flashcardsGridKey.currentState?.fetchFlashcards();
                },
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                labelWidget: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(MyAppLocalizations.of(context).settings.toUpperCase(), style: speedDialChildTextStyle),
                )),
          ],
        ),
      ),
    );
  }

  TextStyle get speedDialChildTextStyle => TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

  void showLessonGeneratorForm(BuildContext context) async {
    final height = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final safeHeight = height - padding.top - padding.bottom;
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: safeHeight),
        builder: (context) {
          return BottomSheetDialog(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Handle(),
                SizedBox(
                  height: 8.0,
                ),
                Flexible(
                  child: LessonGeneratorForm(
                    onGenerate: (flashcards) async {
                      if (ModalRoute.of(context)!.isCurrent) {
                        Navigator.of(context).pop();
                        await Navigator.of(context)
                            .pushNamed(RoutesPaths.lesson, arguments: LessonPageArguments(flashcards));
                        _flashcardsGridKey.currentState?.fetchFlashcards();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
