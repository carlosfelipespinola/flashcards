import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);
  var usecase = FindFlashcardsUseCase(flashcardRepository: flashcardRepository);
  
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

  group('Flashcard find by search term tests: ', () {

    test('when search term matches in flashcard.term the flashcard should be returned', () async {
      final searchTerm = 'awesome';
      final flashcards = [
        Flashcard(
          term: searchTerm,
          definition: 'incrível',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'house',
          definition: 'casa',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase.call(searchTerm: searchTerm);
      expect(flashcardsFound.length, 1);
    });

    test('when search term matches in flashcard.definition the flashcard should be returned', () async {
      final searchTerm = 'awesome';
      final flashcards = [
        Flashcard(
          term: 'incrível',
          definition: searchTerm,
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'house',
          definition: 'casa',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase(searchTerm: searchTerm);
      expect(flashcardsFound.length, 1);
    });

    test("search should'nt be case sensitive", () async {
      final searchTerm = 'AwEsOmE';
      final flashcards = [
        Flashcard(
          term: 'incrível',
          definition: 'awesome',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'house',
          definition: 'casa',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase(searchTerm: searchTerm);
      expect(flashcardsFound.length, 1);
    });

    test('if search term matches at the start, in the middle or at the end of a sentence, the flashcard should be returned', () async {
      final searchTerm = 'threw';
      final flashcards = [
        Flashcard(
          term: 'Bob threw the ball',
          definition: 'Bob lançou a bola',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'threw something',
          definition: 'lançou algo',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'testing a query searching the word threw',
          definition: 'testando uma consulta procurando pela palavra lançou',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'this flashcard should not be returned',
          definition: 'esse flashcard não deve ser retornado',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase(searchTerm: searchTerm);
      expect(flashcardsFound.length, 3);
    });

    test('find flashcards by search term should ignore category', () async {
      final searchTerm = 'awesome';
      final categories = [
        Category(name: 'Category 1', id: null),
        Category(name: 'Category 2', id: null)
      ];
      for (var category in categories) { category = await categoryRepository.save(category); }
      final flashcards = [
        Flashcard(
          term: '$searchTerm term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 1,
          category: categories[0],
          id: null
        ),
        Flashcard(
          term: 'term $searchTerm',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 1,
          category: categories[1],
          id: null
        ),
        Flashcard(
          term: searchTerm,
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 1,
          category: null,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase(searchTerm: searchTerm);
      expect(flashcardsFound.length, 3);
    });

    test('sql injection should not work', () async {
      final searchTerm = '"%awesome';
      final flashcards = [
        Flashcard(
          term: searchTerm,
          definition: 'incrível',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        ),
        Flashcard(
          term: 'house',
          definition: 'casa',
          lastSeenAt: DateTime.now(),
          strength: 1,
          id: null
        )
      ];
      for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      var flashcardsFound = await usecase(searchTerm: searchTerm);
      expect(flashcardsFound.length, 1);
    });

  });

}