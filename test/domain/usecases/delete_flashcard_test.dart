import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  var deleteFlashcardUseCase = DeleteFlashcardUseCase(flashcardRepository: flashcardRepository);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  group('Flashcard delete tests: ', () {

    test('delete flashcards should work', () async {
      final categories = [
        Category(name: 'Category 1', id: null),
        Category(name: 'Category 2', id: null)
      ];
      for (var category in categories) { category = await categoryRepository.save(category); }
      final flashcards = [
        Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 1,
          category: categories[0],
          id: null
        ),
        Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 5,
          category: null,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsCount = (await flashcardRepository.query()).length;
      expect(flashcardsCount, 2);
      await deleteFlashcardUseCase(flashcards[0]);
      flashcardsCount = (await flashcardRepository.query()).length;
      expect(flashcardsCount, 1);
    });

  });

}