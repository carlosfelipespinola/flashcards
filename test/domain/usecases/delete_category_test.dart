import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/delete_category.usecase.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
import 'package:flashcards/services/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  var saveCategoryUseCase = SaveCategoryUseCase(categoryRepository: categoryRepository);
  var deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository: categoryRepository);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
  });

  group('Category delete tests: ', () {

    test('delete category should work', () async {
      await saveCategoryUseCase(Category(name: 'Category'));
      await saveCategoryUseCase(Category(name: 'Category'));
      final categoryCreated = await saveCategoryUseCase(Category(name: 'Category'));
      var categoryCount = (await categoryRepository.findAll()).length;
      expect(categoryCount, 3);
      await deleteCategoryUseCase.call(categoryCreated);
      categoryCount = (await categoryRepository.findAll()).length;
      expect(categoryCount, 2);
    });

  });

}