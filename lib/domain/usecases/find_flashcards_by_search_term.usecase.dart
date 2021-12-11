
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/sort.dart';

class FindFlashcardsBySearchTermUseCase {

  final IFlashcardRepository flashcardRepository;
  FindFlashcardsBySearchTermUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call(String searchTerm) async {
    return await flashcardRepository.query(
      searchTerm: searchTerm,
      anyCategory: true,
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
    );
  }

}
