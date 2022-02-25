
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_filters.dart';
import 'package:flashcards/domain/models/lesson_settings.dart';
import 'package:flashcards/domain/models/sort.dart';

class GenerateLessonUseCase {

  final IFlashcardRepository _flashcardRepository;
  GenerateLessonUseCase({
    required IFlashcardRepository flashcardRepository,
  }) : _flashcardRepository = flashcardRepository;

  Future<List<Flashcard>> call(LessonSettings settings) async {
    final flashcards = await _fetchAllExceptLowPriorityFlashcards(settings: settings);
    final hasNotEnoughFlashcards = flashcards.length < settings.flashcardsCount;
    if (hasNotEnoughFlashcards) {
      final remainingQuantity = settings.flashcardsCount - flashcards.length;
      final lowPriorityCards = await _fetchOnlyLowPriorityFlashcards(settings: settings, quantity: remainingQuantity);
      flashcards.addAll(lowPriorityCards);
    }
    return flashcards;
  }

  Future<List<Flashcard>> _fetchAllExceptLowPriorityFlashcards({required LessonSettings settings}) async {
    return _flashcardRepository.query(
      filters: [
        ExceptLowPriorityFlashcardsFilter(),
        FlashcardCategoryFilter(category: settings.category)
      ],
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
      limit: settings.flashcardsCount
    );
  }

  Future<List<Flashcard>> _fetchOnlyLowPriorityFlashcards({required LessonSettings settings, required int quantity}) async  {
    return _flashcardRepository.query(
      filters: [
        OnlyLowPriorityFlashcardsFilter(),
        FlashcardCategoryFilter(category: settings.category)
      ],
      sortBy: [
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
      limit: quantity
    );
  }
}
