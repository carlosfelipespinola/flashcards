
import 'package:flashcards/data/category.mapper.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flashcards/domain/models/flashcard_sortable_fields.dart';
import 'package:flashcards/domain/models/sort.dart';

class FlashcardMapper {
  static Flashcard fromMap(Map<String, dynamic> map) {
    final flashcard = Flashcard(
      id: map[FlashcardSchema.id] as int,
      term: map[FlashcardSchema.term] as String,
      definition: map[FlashcardSchema.definition] as String,
      lastSeenAt: DateTime.parse(map[FlashcardSchema.lastSeenAt]),
      strength: map[FlashcardSchema.strength] as int,
      category: map[CategorySchema.id] != null ? CategoryMapper.fromMap(map) : null
    );
    if (map[FlashcardSchema.enteredLowAt] != null && map[FlashcardSchema.exitsLowAt] != null) {
      final enteredAt = DateTime.parse(map[FlashcardSchema.enteredLowAt]);
      final existsAt = DateTime.parse(map[FlashcardSchema.exitsLowAt]);
      final duration = existsAt.difference(enteredAt);
      int? lowPriorityStrength;
      if (map.containsKey(FlashcardSchema.lowPriorityStrength)) {
        lowPriorityStrength = map[FlashcardSchema.lowPriorityStrength];
      }
      final lowPriorityFlashcard = LowPriorityFlashcard(
        base: flashcard,
        lowPriorityStrength: lowPriorityStrength ?? flashcard.strength,
        lowPriorityInfo: LowPriorityInfo(
          enterDateTime: enteredAt,
          duration:  duration
        )
      );
      if (lowPriorityFlashcard.isStillLowPriority) {
        return lowPriorityFlashcard;
      }
    }
    return flashcard;
  }

  static Map<String, dynamic> toMap(Flashcard flashcard) {
    final map = <String, dynamic>{
      FlashcardSchema.id: flashcard.id,
      FlashcardSchema.term: flashcard.term,
      FlashcardSchema.definition: flashcard.definition,
      FlashcardSchema.lastSeenAt: flashcard.lastSeenAt.toIso8601String(),
      FlashcardSchema.strength: flashcard.strength,
      FlashcardSchema.category: flashcard.category != null ? flashcard.category!.id : null,
      if (flashcard is LowPriorityFlashcard && flashcard.isStillLowPriority) ...{
        FlashcardSchema.enteredLowAt: flashcard.lowPriorityInfo.enterDateTime.toIso8601String(),
        FlashcardSchema.exitsLowAt: flashcard.lowPriorityInfo.expiresAt.toIso8601String(),
        FlashcardSchema.lowPriorityStrength: flashcard.lowPriorityStrength
      } else ...{
        FlashcardSchema.enteredLowAt: null,
        FlashcardSchema.exitsLowAt: null,
        FlashcardSchema.lowPriorityStrength: null
      }
    };
    return map;
  }

  static String mapSortToSql (Sort<FlashcardSortableFields> sort) {
    final type = sort.type == SortType.asc ? 'asc' : 'desc';
    switch (sort.field) {
      case FlashcardSortableFields.strength:
        return '${FlashcardSchema.strength} $type';
      case FlashcardSortableFields.lowPriorityStrength:
        return '${FlashcardSchema.lowPriorityStrength} $type';
      default:
        return 'datetime(${FlashcardSchema.lastSeenAt}) $type';
    }
  }
}