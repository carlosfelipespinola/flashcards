import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
import 'package:flashcards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  var saveCategoryUseCase = SaveCategoryUseCase(categoryRepository: categoryRepository);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
  });

  group('Category save tests: ', () {

    test('create category should work', () async {
      final category = Category(name: 'Category');
      final categoryCreated = await saveCategoryUseCase(category);
      expect(categoryCreated.id == null, false);
      expect(categoryCreated.name, category.name);
    });

    test('update category should work', () async {
      final category = Category(name: 'Category');
      final categoryCreated = await saveCategoryUseCase(category);
      expect(categoryCreated.id == null, false);
      expect(categoryCreated.name, 'Category');
      final categorySaved = await saveCategoryUseCase(categoryCreated..name = 'Category 2');
      expect(categorySaved.name, 'Category 2');
    });

  });

}