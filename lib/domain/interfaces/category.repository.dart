
import 'package:flashcards/domain/models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> findAll({bool countFlashcards = false});
  Future<Category> save(Category tag);
  Future<Category> delete(Category tag);
}