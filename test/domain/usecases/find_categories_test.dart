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

  group('Category find tests: ', () {

    test('find categories should work', () async {
      await saveCategoryUseCase(Category(name: 'Category 1'));
      await saveCategoryUseCase(Category(name: 'Category 2'));
      await saveCategoryUseCase(Category(name: 'Category 3'));
      var categoryCount = (await categoryRepository.findAll()).length;
      expect(categoryCount, 3);
    });

  });

}