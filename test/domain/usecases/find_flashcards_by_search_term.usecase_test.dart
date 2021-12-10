import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/usecases/find_flashcards_by_search_term.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var usecase = FindFlashcardsBySearchTermUseCase(flashcardRepository: flashcardRepository);
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
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
      var flashcardsFound = await usecase(searchTerm);
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
      var flashcardsFound = await usecase(searchTerm);
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
      var flashcardsFound = await usecase(searchTerm);
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
      var flashcardsFound = await usecase(searchTerm);
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
      var flashcardsFound = await usecase(searchTerm);
      expect(flashcardsFound.length, 1);
    });

  });

}