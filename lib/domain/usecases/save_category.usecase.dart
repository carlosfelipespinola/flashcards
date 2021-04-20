import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';

class SaveCategoryUseCase {

  final ICategoryRepository categoryRepository;
  SaveCategoryUseCase({
    required this.categoryRepository,
  });

  Future<Category> call(Category tag) async {
    return await categoryRepository.save(tag);
  }

}
