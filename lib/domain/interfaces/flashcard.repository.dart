
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/category.dart';

import '../models/fashcard.dart';

abstract class IFlashcardRepository {
  
  Future<List<Flashcard>> findAll();
  Future<Flashcard> save(Flashcard flashcard);
  Future<Flashcard> delete(Flashcard flashcard);
  Future<List<Flashcard>> query({
    Category? category,
    List<Sort<FlashcardSortableFields>>? sortBy,
    int? limit
  });
}