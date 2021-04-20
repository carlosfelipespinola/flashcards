
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/domain/models/category.dart';

class GenerateLessonUseCase {

  final IFlashcardRepository flashcardRepository;
  GenerateLessonUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call(Category category, int limit) async {
    // TODO IDEIA
    // 10% flashcards priorizando mais antigos com alto aprendizado;
    // 30% flashcards priorizando primeiramente mais antigos depois baixo aprendizado;
    // 60% flashcards priorizando primeiramente baixo aprendizado depois idade
    return await this.flashcardRepository.query(
      category: category,
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
      limit: limit,
      randomize: true,
    );
  }

}
