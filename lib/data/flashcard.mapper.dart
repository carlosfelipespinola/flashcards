
import 'package:flashcards/data/category.mapper.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class FlashcardMapper {
  static Flashcard fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map[FlashcardSchema.id] as int,
      term: map[FlashcardSchema.term] as String,
      definition: map[FlashcardSchema.definition] as String,
      lastSeenAt: DateTime.parse(map[FlashcardSchema.lastSeenAt]),
      strength: map[FlashcardSchema.strength] as int,
      category: CategoryMapper.fromMap(map)
    );
  }

  static Map<String, dynamic> toJson(Flashcard flashcard) {
    return <String, dynamic>{
      FlashcardSchema.id: flashcard.id,
      FlashcardSchema.term: flashcard.term,
      FlashcardSchema.definition: flashcard.definition,
      FlashcardSchema.lastSeenAt: flashcard.lastSeenAt.toIso8601String(),
      FlashcardSchema.strength: flashcard.strength,
      FlashcardSchema.category: flashcard.category.id
    };
  }
}