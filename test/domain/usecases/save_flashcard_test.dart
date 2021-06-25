import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/save_flashcard.usecase.dart';
import 'package:flashcards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  var saveFlashcard = SaveFlashcardUseCase(flashcardRepository: flashcardRepository);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  group('Flashcard save tests: ', () {

    test('create flashcards should work', () async {
      final categories = [
        Category(name: 'Category 1', id: null),
        Category(name: 'Category 2', id: null)
      ];
      for (var category in categories) {
        category = await categoryRepository.save(category);
      }
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
        ),
        Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 1,
          category: null,
          id: null
        )
      ];
      for (var flashcard in flashcards) {
        try {
          final flashcardCreated = await saveFlashcard(flashcard);
          expect(flashcardCreated.id == null, false);
        } catch (error) {
          expect(true, false);
        }
      }
    });

    test('create flashcard should fail because strength is invalid', () async {
      final flashcards = [
        Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 0,
          category: null,
          id: null
        ),
        Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 6,
          category: null,
          id: null
        ),
      ];
      for (var flashcard in flashcards) {
        bool hasFailed = false;
        try {
          await saveFlashcard(flashcard);
        } catch (_) {
          hasFailed = true;
        }
        expect(hasFailed, true);
      }
    });

    test('update flashcard should work', () async {
      final categories = [
        Category(name: 'Category 1', id: null),
        Category(name: 'Category 2', id: null)
      ];
      for (var category in categories) {
        category = await categoryRepository.save(category);
      }
      final flashcard = Flashcard(
        term: 'term',
        definition: 'definition',
        lastSeenAt: DateTime.now(),
        strength: 1,
        category: categories[0],
        id: null
      );
      final flashcardCreated = await saveFlashcard(flashcard);
      expect(flashcardCreated.id == null, false);
      
      flashcardCreated.term = 'a';
      flashcardCreated.definition = 'b';
      flashcardCreated.markAsSeenNow();
      flashcardCreated.increaseStrength();
      flashcardCreated.category = categories[1];

      final flashcardSaved = await saveFlashcard(flashcardCreated);
      expect(flashcardSaved.id == null, false);
    });

  });

}