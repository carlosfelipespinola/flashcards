
import 'package:flashcards/domain/models/flashcard_filters.dart';
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/category.dart';

import '../models/fashcard.dart';

abstract class IFlashcardRepository {
  
  Future<List<Flashcard>> findAll({List<Sort<FlashcardSortableFields>>? sortBy});
  Future<Flashcard> save(Flashcard flashcard);
  Future<Flashcard> delete(Flashcard flashcard);

  /// when [isLowPriority] is null, both must be returned (low priority and hight priority)
  // TODO [refactoring] convert category and search filters to FlashcardFilter
  Future<List<Flashcard>> query({
    List<FlashcardFilter> filters = const [],
    Category? category,
    bool anyCategory = false,
    List<Sort<FlashcardSortableFields>>? sortBy,
    String? searchTerm,
    int? limit
  });
}