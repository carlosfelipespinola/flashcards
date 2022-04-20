
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_filters.dart';
import 'package:flashcards/domain/models/flashcard_sortable_fields.dart';
import 'package:flashcards/domain/models/sort.dart';

class FindFlashcardsUseCase {

  final IFlashcardRepository flashcardRepository;
  FindFlashcardsUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call({String? searchTerm}) async {
    if (searchTerm != null && searchTerm.isNotEmpty) {
      return await flashcardRepository.query(
        filters: [
          FlashcardSearchFilter(search: searchTerm)
        ],
        sortBy: _sortRules,
      );
    } else {
      return await flashcardRepository.query(
        sortBy: _sortRules
      );
    }
  }

  List<Sort<FlashcardSortableFields>> get _sortRules => [
    Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
    Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
  ];

}
