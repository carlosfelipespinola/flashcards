
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/sort.dart';

class FindFlashcardsUseCase {

  final IFlashcardRepository flashcardRepository;
  FindFlashcardsUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call({String? searchTerm}) async {
    if (searchTerm != null && searchTerm.isNotEmpty) {
      return await flashcardRepository.query(
        searchTerm: searchTerm,
        anyCategory: true,
        sortBy: [
          Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
          Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
        ],
      );
    } else {
      return await flashcardRepository.findAll(
        sortBy: [
          Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
          Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
        ],
      );
    }
  }

}
