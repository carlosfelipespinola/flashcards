import 'dart:convert';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class _FlashcardJsonKeys {
  static String id = 'id';
  static String term = 'term';
  static String definition = 'definition';
  static String lastSeenAt = 'lastSeenAt';
  static String strength = 'strength';
  static String categoryName = 'categoryName';
  static String categoryId = 'categoryId';
}

class FlashcardJsonMapper {
  static String toJson(Flashcard flashcard) => jsonEncode(_toMap(flashcard));

  // may throw CorruptedDataFailure
  static Flashcard fromJson(String json) {
    try {
      return _fromMap(jsonDecode(json));
    } catch (_) {
      throw CorruptedDataFailure();
    }
  }

  static Flashcard _fromMap(Map<String, dynamic> map) {
    return Flashcard(
        id: map[_FlashcardJsonKeys.id] as int,
        term: map[_FlashcardJsonKeys.term] as String,
        definition: map[_FlashcardJsonKeys.definition] as String,
        lastSeenAt: DateTime.parse(map[_FlashcardJsonKeys.lastSeenAt]),
        strength: map[_FlashcardJsonKeys.strength] as int,
        category: map[_FlashcardJsonKeys.categoryId] != null
            ? Category(id: map[_FlashcardJsonKeys.categoryId], name: map[_FlashcardJsonKeys.categoryName])
            : null);
  }

  static Map<String, dynamic> _toMap(Flashcard flashcard) {
    final map = <String, dynamic>{
      _FlashcardJsonKeys.id: flashcard.id,
      _FlashcardJsonKeys.term: flashcard.term,
      _FlashcardJsonKeys.definition: flashcard.definition,
      _FlashcardJsonKeys.lastSeenAt: flashcard.lastSeenAt.toIso8601String(),
      _FlashcardJsonKeys.strength: flashcard.strength,
      _FlashcardJsonKeys.categoryId: flashcard.category?.id ?? null,
      _FlashcardJsonKeys.categoryName: flashcard.category?.name ?? null
    };
    return map;
  }
}
