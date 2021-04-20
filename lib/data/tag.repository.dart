
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';

class CategoryRepository implements ICategoryRepository {
  @override
  Future<Category> delete(Category tag) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> findAll() {
    throw UnimplementedError();
  }

  @override
  Future<Category> save(Category tag) {
    throw UnimplementedError();
  }

}