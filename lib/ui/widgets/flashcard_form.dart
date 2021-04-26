import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/save_flashcard.usecase.dart';
import 'package:flashcards/ui/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/ui/widgets/text_area_card.dart';
import 'package:get_it/get_it.dart';

class FlashcardForm extends StatefulWidget {
  final Flashcard flashcard;
  final Function? onFlashcardSaved;

  const FlashcardForm({Key? key, required this.flashcard, this.onFlashcardSaved}) : super(key: key);

  @override
  _FlashcardFormState createState() => _FlashcardFormState();
}

enum FlashcardFormSaveState { unset, pending, saved, error }

class _FlashcardFormState extends State<FlashcardForm> {
  late TextEditingController _termController;
  late TextEditingController _definitionController;
  final _frontFocusNode = FocusNode();
  final _backFocusNode = FocusNode();
  final SaveFlashcardUseCase saveFlashcardUseCase = GetIt.I();
  var state = FlashcardFormSaveState.unset;
  Category? selectedCategory;

  @override
  void initState() {
    _termController = TextEditingController(text:  widget.flashcard.term);
    _definitionController = TextEditingController(text: widget.flashcard.definition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: state == FlashcardFormSaveState.pending,
      child: Form(
        autovalidateMode: AutovalidateMode.disabled,
        onWillPop: state == FlashcardFormSaveState.pending ? () async => false : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextAreaCard(
              label: 'Frente',
              focusNode: _frontFocusNode,
              textInputAction: _definitionController.text.isNotEmpty ? TextInputAction.done : TextInputAction.next,
              controller: _termController,
              onChange: onTermChanged,
              onEditingComplete: _definitionController.text.isNotEmpty ? null : () {
                FocusScope.of(context).requestFocus(_backFocusNode);
              },
              maxLength: 100,
            ),
            SizedBox(height: 12,),
            TextAreaCard(
              label: 'Trás',
              textInputAction: TextInputAction.done,
              controller: _definitionController,
              onChange: onDefinitionChanged,
              focusNode: _backFocusNode,
              maxLength: 100,
            ),
            SizedBox(height: 12,),
            CategoryPicker(
              selectedCategory: selectedCategory,
              onChange: onCategoryChanged
            ),
            SizedBox(height: 12,),
            ElevatedButton.icon(
              onPressed: widget.flashcard.isValid() ? () {} : null,
              icon: Icon(Icons.save),
              label: Text('Salvar'.toUpperCase())
            )
          ],
        )  
      ),
    );
  }

  void save() async {
    try {
      setState(() { state = FlashcardFormSaveState.pending; });
      await saveFlashcardUseCase.call(widget.flashcard);
      setState(() { state = FlashcardFormSaveState.saved; });
      if (widget.onFlashcardSaved != null) {
        widget.onFlashcardSaved!();
      }
    } catch (error) {
      setState(() { state = FlashcardFormSaveState.error; });
    }
  }

  void onCategoryChanged(Category? category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onTermChanged(String term) {}

  void onDefinitionChanged(String definition) {}

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _termController.dispose();
    _definitionController.dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
  }
}