import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';

class FindCategoriesUseCase {

  final ICategoryRepository categoryRepository;
  FindCategoriesUseCase({
    required this.categoryRepository,
  });

  Future<List<Category>> call({bool countFlashcards = false}) async {
    return await categoryRepository.findAll(countFlashcards: countFlashcards);
  }

}
