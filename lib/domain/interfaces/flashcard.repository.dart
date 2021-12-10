
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/category.dart';

import '../models/fashcard.dart';

abstract class IFlashcardRepository {
  
  Future<List<Flashcard>> findAll({List<Sort<FlashcardSortableFields>>? sortBy});
  Future<Flashcard> save(Flashcard flashcard);
  Future<Flashcard> delete(Flashcard flashcard);
  Future<List<Flashcard>> query({
    Category? category,
    List<Sort<FlashcardSortableFields>>? sortBy,
    String? searchTerm,
    int? limit
  });
}