import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/category_flashcards_count.dart';

class FindCategoriesCountingFlashcardsUseCase {

  final ICategoryRepository categoryRepository;
  final IFlashcardRepository flashcardRepository;
  FindCategoriesCountingFlashcardsUseCase({
    required this.categoryRepository,
    required this.flashcardRepository
  });

  Future<List<CategoryFlashcardsCount>> call() async {
    final List<CategoryFlashcardsCount> categoriesFlashcardsCount = [];
    final categories = await categoryRepository.findAll(countFlashcards: true);
    final flashcardsWithoutCategory = (await flashcardRepository.query(category: null)).length;
    for (var category in categories) {
      categoriesFlashcardsCount.add(CategoryFlashcardsCount(
        category: category,
        flashcardsCount: category.flashcardsCount ?? 0)
      );
    }
    categoriesFlashcardsCount.add(
      CategoryFlashcardsCount(category: null, flashcardsCount: flashcardsWithoutCategory)
    );
    return categoriesFlashcardsCount;
  }

}
