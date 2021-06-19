
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/lesson_settings.dart';
import 'package:flashcards/domain/models/sort.dart';

class GenerateLessonUseCase {

  final IFlashcardRepository flashcardRepository;
  GenerateLessonUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call(LessonSettings settings) async {
    return await this.flashcardRepository.query(
      category: settings.category,
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
      limit: settings.flashcardsCount,
      randomize: true,
    );
  }

}
