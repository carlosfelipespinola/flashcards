
import 'package:flashcards/domain/models/tag.dart';

enum FlashcardSortableFields { lastSeentAt, strength }

class Flashcard {
  String? id;
  String _term;
  String _definition;
  DateTime _lastSeenAt;
  int _strength;
  List<Tag> _tags;

  String get term => _term;
  String get definition => _definition;
  DateTime get lastSeenAt => _lastSeenAt; 
  List<Tag> get tags => _tags;

  Flashcard({
    required this.id,
    required String term,
    required String definition,
    required DateTime lastSeenAt,
    required int strength,
    required List<Tag> tags,
  }) : 
    _term = term, _definition = definition, 
    _lastSeenAt = lastSeenAt, _strength = strength, _tags = tags;

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
