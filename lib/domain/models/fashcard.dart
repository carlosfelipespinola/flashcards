import 'package:flashcards/domain/models/category.dart';

enum FlashcardSortableFields { lastSeentAt, strength }

class Flashcard {
  int? id;
  String _term;
  String _definition;
  DateTime _lastSeenAt;
  int _strength;
  Category _category;

  String get term => _term;
  String get definition => _definition;
  DateTime get lastSeenAt => _lastSeenAt; 
  Category get category => _category;
  int get strength => _strength;

  Flashcard({
    required this.id,
    required String term,
    required String definition,
    required DateTime lastSeenAt,
    required int strength,
    required Category category,
  }) : 
    _term = term, _definition = definition, 
    _lastSeenAt = lastSeenAt, _strength = strength, _category = category;

  void increaseStrength() {
    _strength = _strength >= 5 ? 5 : _strength++;
  }

  void decreaseStrength() {
    _strength = _strength <= 1 ? 1 : _strength--;
  }

  void markAsSeenNow() {
    _lastSeenAt = DateTime.now();
  }

  bool isValid() {
    if (_strength < 1 || _strength > 5)
      return false;
    return true;
  }
}
