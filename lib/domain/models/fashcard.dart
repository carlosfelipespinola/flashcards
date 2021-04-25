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

  factory Flashcard.create() {
    return Flashcard(
      term: '',
      definition: '',
      lastSeenAt: DateTime.now(),
      strength: 1,
      category: null,
      id: null
    );
  }

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
    if (term.length < 1 || definition.length < 1) {
      return false;
    }
    return true;
  }

  Flashcard copyWith({
    int? id,
    String? term,
    String? definition,
    DateTime? lastSeenAt,
    int? strength,
    Category? category,
  }) {
    return Flashcard(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      lastSeenAt: lastSeenAt ?? this._lastSeenAt,
      strength: strength ?? this._strength,
      category: category ?? this.category,
    );
  }
}
