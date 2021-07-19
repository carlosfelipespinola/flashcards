import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/services/app_info/app_info.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.arguments.dart';
import 'package:flashcards/ui/pages/lesson/lesson.page.arguments.dart';
import 'package:flashcards/ui/widgets/confirm_bottom_dialog.dart';
import 'package:flashcards/ui/widgets/flashcard_details_bottom_dialog.dart';
import 'package:flashcards/ui/widgets/flashcards_grid.dart';
import 'package:flashcards/ui/widgets/lesson_generator_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';

import '../../../router.dart';

class FlashcardsPage extends StatefulWidget {
  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {

  GlobalKey<FlashcardGridState> _flashcardsGridKey = GlobalKey();

  final DeleteFlashcardUseCase deleteFlashcardUseCase = GetIt.I();

  Set<Flashcard> flashcardsBeingDeleted = {};

  bool shouldHideFloatingActionButton = false;

  AppInfo _appInfo = GetIt.I<AppInfo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FlashcardGrid(
          key: _flashcardsGridKey,
          onFlashcardLongPress: (flashcard) => showFlashcardBottomDialog(flashcard),
          onScrollBottomEnter: () => setState(() { shouldHideFloatingActionButton = true; }),
          onScrollBottomExit: () => setState(() { shouldHideFloatingActionButton = false; }),
        )
      ),
      floatingActionButton: shouldHideFloatingActionButton ? Container() : SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: true,
        curve: Curves.bounceIn,
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
              child: Text('Criar Flashcard'.toUpperCase(), style: speedDialChildTextStyle),
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
              child: Text('Praticar'.toUpperCase(), style: speedDialChildTextStyle),
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
              child: Text('Gerenciar categorias'.toUpperCase(), style: speedDialChildTextStyle),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.lock_open),
            onTap: () async => showLicensePage(
              context: context,
              applicationIcon: _appInfo.appIconPath != null ? CircleAvatar(child: Image.asset(_appInfo.appIconPath!)) : null,
              applicationVersion: _appInfo.appVersion
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text('Licenças de código aberto'.toUpperCase(), style: speedDialChildTextStyle),
            )
          ),
        ],
      ),
    );
  }

  TextStyle get speedDialChildTextStyle => TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

  void showFlashcardBottomDialog(Flashcard flashcard) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return FlashcardDetailsBottomDialog(
          flashcard: flashcard,
          onEdit: () async {
            if (ModalRoute.of(context)!.isCurrent) {
              Navigator.of(context).pop();
            }
            await Navigator.of(context).pushNamed(
              RoutesPaths.flashcardEditor,
              arguments: FlashcardEditorPageArguments(flashcard: flashcard)
            );
            _flashcardsGridKey.currentState?.fetchFlashcards();
            
          },
          onDelete: () {
            if (ModalRoute.of(context)!.isCurrent) {
              Navigator.of(context).pop();
            }
            showFlashcardDeletionConfirmDialog(flashcard);
          }
        );
      }
    );
  }

  void showFlashcardDeletionConfirmDialog(Flashcard flashcard) async {
    if (flashcardsBeingDeleted.contains(flashcard)) return;
    final shouldDelete = await showModalBottomSheet<bool?>(
      isScrollControlled: false,
      context: context,
      builder: (context) {
        return ConfirmBottomDialog(
          title: 'Deletar Flashcard',
          text: 'Você tem certeza que deseja deletar esse flashcard?',
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false)
        );
      }
    ) ?? false;
    if (shouldDelete) {
      await deleteFlashcard(flashcard);
      _flashcardsGridKey.currentState?.fetchFlashcards();
    }
  }

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

  Future<void> deleteFlashcard(Flashcard flashcard) async {
    try {
      flashcardsBeingDeleted.add(flashcard);
      await deleteFlashcardUseCase(flashcard);
      showMessage('Flashcard deletado com sucesso');
    } catch(_) {
      showMessage('Erro ao deletar flashcard');
    } finally {
      flashcardsBeingDeleted.remove(flashcard);
    }
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}