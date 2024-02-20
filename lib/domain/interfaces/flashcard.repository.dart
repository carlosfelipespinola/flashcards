import 'package:flashcards/domain/models/flashcard_filters.dart';
import 'package:flashcards/domain/models/flashcard_sortable_fields.dart';
import 'package:flashcards/domain/models/sort.dart';

import '../models/fashcard.dart';

abstract class IFlashcardRepository {
  Future<Flashcard> save(Flashcard flashcard);

  Future<Flashcard> delete(Flashcard flashcard);

  Future<List<Flashcard>> query(
      {List<FlashcardFilter> filters = const [],
      List<Sort<FlashcardSortableFields>>? sortBy,
      int? limit});

  Future<bool> exists({required String term, required String definition});
}
