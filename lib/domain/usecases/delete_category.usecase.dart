import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';

class DeleteCategoryUseCase {

  final ICategoryRepository categoryRepository;
  DeleteCategoryUseCase({
    required this.categoryRepository,
  });

  Future<Category> call(Category tag) async {
    return await categoryRepository.delete(tag);
  }

}
