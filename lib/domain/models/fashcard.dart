import 'package:flashcards/domain/models/category.dart';

enum FlashcardSortableFields { lastSeentAt, strength }

class Flashcard {
  int? id;
  String term;
  String definition;
  DateTime _lastSeenAt;
  int _strength;
  Category? category;

  DateTime get lastSeenAt => _lastSeenAt;
  int get strength => _strength;

  Flashcard({
    this.id,
    required this.term,
    required this.definition,
    required DateTime lastSeenAt,
    required int strength,
    this.category,
  }) :
    _lastSeenAt = lastSeenAt, _strength = strength;

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
