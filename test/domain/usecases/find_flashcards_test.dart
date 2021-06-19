import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  group('Flashcard find tests: ', () {

    test('find flashcards should work', () async {
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
          strength: 1,
          category: categories[1],
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await flashcardRepository.findAll();
      expect(flashcardsFound.length, 2);
      for (var flashcard in flashcards) {
        expect(flashcard.category != null, true);
        expect(flashcard.category?.id != null, true);
        expect(flashcard.category?.name != null, true);
      }
    });

  });

}