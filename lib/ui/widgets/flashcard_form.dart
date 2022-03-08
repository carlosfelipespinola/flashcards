import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/save_flashcard.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/ui/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/ui/widgets/text_area_card.dart';
import 'package:get_it/get_it.dart';

class FlashcardForm extends StatefulWidget {
  final Flashcard? flashcard;
  final Function? onFlashcardSaved;

  const FlashcardForm({Key? key, required this.flashcard, this.onFlashcardSaved}) : super(key: key);

  @override
  _FlashcardFormState createState() => _FlashcardFormState();
}

enum FlashcardFormSaveState { unset, pending, saved, error }

class _FlashcardFormState extends State<FlashcardForm> {
  late TextEditingController _termController;
  late TextEditingController _definitionController;
  Category? _selectedCategory;
  final _frontFocusNode = FocusNode();
  final _backFocusNode = FocusNode();
  final SaveFlashcardUseCase saveFlashcardUseCase = GetIt.I();
  var state = FlashcardFormSaveState.unset;
  late Flashcard _flashcard;
  bool _isValid = false;

  @override
  void initState() {
    _flashcard = widget.flashcard?.copyWith() ?? Flashcard.create(); 
    _termController = TextEditingController(text:  _flashcard.term);
    _definitionController = TextEditingController(text: _flashcard.definition);
    _selectedCategory = _flashcard.category?.copyWith();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlashcardForm oldWidget) {
    if (oldWidget.flashcard?.id != widget.flashcard?.id) {
      _flashcard = widget.flashcard?.copyWith() ?? Flashcard.create(); 
      _selectedCategory = _flashcard.category?.copyWith();
      _termController.text = _flashcard.term;
      _definitionController.text = _flashcard.definition;
      _termController.selection = TextSelection.fromPosition(TextPosition(offset: _termController.text.length));
      _definitionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _definitionController.text.length)
      );
    }
    super.didUpdateWidget(oldWidget);
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
              label: MyAppLocalizations.of(context).frontSide,
              focusNode: _frontFocusNode,
              textInputAction: _definitionController.text.isNotEmpty ? TextInputAction.done : TextInputAction.next,
              controller: _termController,
              onChange: (_) => validate(),
              onEditingComplete: _definitionController.text.isNotEmpty ? null : () {
                FocusScope.of(context).requestFocus(_backFocusNode);
              },
              maxLength: 100,
            ),
            SizedBox(height: 12,),
            TextAreaCard(
              label: MyAppLocalizations.of(context).backSide,
              textInputAction: TextInputAction.done,
              controller: _definitionController,
              onChange: (_) => validate(),
              focusNode: _backFocusNode,
              maxLength: 100,
            ),
            SizedBox(height: 12,),
            CategoryPicker(
              selectedCategory: _selectedCategory,
              onChange: onCategoryChanged,
              onBeforeShowCategoryPicker: () => FocusScope.of(context).unfocus(),
            ),
            if ( state == FlashcardFormSaveState.error ) ... [
              SizedBox(height: 12,),
              Text(
                MyAppLocalizations.of(context).defaultErrorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).errorColor)
              ),
            ],
            SizedBox(height: 12,),
            ElevatedButton.icon(
              onPressed: canSave ? save : null,
              icon: Icon(Icons.save),
              label: Text(MyAppLocalizations.of(context).save.toUpperCase())
            )
          ],
        )  
      ),
    );
  }

  void save() async {
    try {
      setState(() { state = FlashcardFormSaveState.pending; });
      final flashcard = _flashcard.copyWith();
      flashcard.term = _termController.text;
      flashcard.definition = _definitionController.text;
      flashcard.category = _selectedCategory;
      _flashcard = await saveFlashcardUseCase.call(flashcard);
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
      _selectedCategory = category;
    });
    validate();
  }

  bool get canSave => hasChanges && _isValid && isNotSaving;

  bool get isNotSaving => state != FlashcardFormSaveState.pending;

  bool get hasChanges {
    if (_termController.text != _flashcard.term) return true;
    if (_definitionController.text != _flashcard.definition) return true;
    if (_selectedCategory?.id != _flashcard.category?.id) return true;
    return false;
  }

  void validate() {
    setState(() {
      _isValid = _termController.text.length > 0 && _definitionController.text.length > 0;
    });
  }

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