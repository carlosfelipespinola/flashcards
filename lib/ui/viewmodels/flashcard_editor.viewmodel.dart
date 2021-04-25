
import 'package:flashcards/domain/models/category.dart';
import 'package:flutter/material.dart';

import 'package:flashcards/domain/models/fashcard.dart';

class FlashcardEditorViewModel extends ChangeNotifier {
  Flashcard _flashcard;
  bool isSaving = false;

  FlashcardEditorViewModel._({
    required Flashcard flashcard,
  }) : this._flashcard = flashcard;

  factory FlashcardEditorViewModel.creator() {
    return FlashcardEditorViewModel._(flashcard: Flashcard.create());
  }

  factory FlashcardEditorViewModel.editor(Flashcard flashcard) {
    return FlashcardEditorViewModel._(flashcard: flashcard.copyWith());
  }

  String get term => _flashcard.term;
  set term(String value) {
    _flashcard.term = value;
    notifyListeners();
  }

  get definition => _flashcard.term;
  set definition(value) {
    _flashcard.definition = value;
    notifyListeners();
  }

  Category? get category => _flashcard.category;
  set category(Category? category) {
    _flashcard.category = category;
    notifyListeners();
  }
  

  bool get editMode => true;

  bool get canSave {
    return _flashcard.isValid();
  }

  void save() {
    isSaving = true;
  }
}
