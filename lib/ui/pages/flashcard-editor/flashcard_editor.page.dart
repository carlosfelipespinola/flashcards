import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.arguments.dart';
import 'package:flashcards/ui/widgets/flashcard_form.dart';
import 'package:flutter/material.dart';

class FlashcardEditorPage extends StatelessWidget {
  final FlashcardEditorPageArguments arguments;

  const FlashcardEditorPage({Key? key, required this.arguments}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.toUpperCase())),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FlashcardForm(
            flashcard: arguments.flashcard ?? Flashcard.create(),
            onFlashcardSaved: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage))
              );
              if(ModalRoute.of(context)!.isCurrent) {
                Navigator.of(context).pop();
              }
            },
          )
        ),
      ),
    );
  }

  bool get isEditing => arguments.flashcard != null;

  String get title {
    if (isEditing) return 'Atualizar Flashcard';
    return 'Criar Flashcard';
  }

  String get successMessage {
    if (isEditing) return 'Flashcard atualizado com sucesso';
    return 'Flashcard cadastrado com sucesso';
  }
}
