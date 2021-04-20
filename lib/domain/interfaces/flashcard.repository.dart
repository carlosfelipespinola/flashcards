
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/tag.dart';

import '../models/fashcard.dart';

abstract class IFlashcardRepository {
  
  Future<List<Flashcard>> findAll();
  Future<Flashcard> save(Flashcard flashcard);
  Future<Flashcard> delete(Flashcard flashcard);
  Future<List<Flashcard>> query({
    List<Tag>? tags,
    List<Sort<FlashcardSortableFields>>? sortBy,
    int? limit,
    bool? randomize = false
  });
}