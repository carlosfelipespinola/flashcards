
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/tag.dart';

class GenerateLessonUseCase {

  final IFlashcardRepository flashcardRepository;
  GenerateLessonUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call(List<Tag> tags, int limit) async {
    return await this.flashcardRepository.query(
      tags: tags,
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
      limit: limit,
      randomize: true,
    );
  }

}
