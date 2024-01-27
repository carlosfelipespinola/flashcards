import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/interfaces/flashcard_backup_service.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/usecases/import_flashcards.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FlashcardBackupServiceTest implements IFlashcardBackupService {
  List<Flashcard> _flashcards = [];

  FlashcardBackupServiceTest({required List<Flashcard> flashcards}) : _flashcards = flashcards;

  @override
  Future<void> backup(List<Flashcard> flashcards) {
    _flashcards.clear();
    _flashcards.addAll(flashcards);
    return Future.value();
  }

  @override
  Future<List<Flashcard>> restore() {
    return Future.value(_flashcards);
  }
}

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var categoryRepository = CategoryRepository(databaseProvider: dbProvider);

  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  group('Import flashcards tests...', () {
    test(
        'When importing flashcards having an empty database, all flashcards and categories should be imported, and all ids should be redefined',
        () async {
      var backupService = FlashcardBackupServiceTest(flashcards: [
        Flashcard(
            id: 10,
            term: 'term1',
            definition: 'definition1',
            lastSeenAt: DateTime.now(),
            strength: 2,
            category: Category(id: 10, name: "Category1")),
        Flashcard(
            id: 11,
            term: 'term2',
            definition: 'definition2',
            lastSeenAt: DateTime.now(),
            strength: 2,
            category: Category(id: 10, name: "Category1")),
        Flashcard(
            id: 12,
            term: 'term3',
            definition: 'definition3',
            lastSeenAt: DateTime.now(),
            strength: 2,
            category: Category(id: 12, name: "Category2")),
        Flashcard(
            id: 13, term: 'term4', definition: 'definition4', lastSeenAt: DateTime.now(), strength: 2, category: null),
      ]);

      var importFlashcards = ImportFlashcardsUseCase(
          flashcardRepository: flashcardRepository,
          categoryRepository: categoryRepository,
          flashcardBackupService: backupService);

      await importFlashcards.call(resetFlashcadsStrength: false).last;

      var categories = await categoryRepository.findAll();
      expect(categories.length, 2);

      var oldCategoriesIds = [10, 12];
      var foundOldCategoryId =
          categories.map((e) => e.id).firstWhere((id) => oldCategoriesIds.contains(id), orElse: () => null);
      expect(foundOldCategoryId, isNull);

      var flashcards = await flashcardRepository.query();
      expect(flashcards.length, 4);

      var oldFlashcardsIds = [10, 11, 12, 13];
      var foundOldFlashcardId =
          flashcards.map((e) => e.id).firstWhere((id) => oldFlashcardsIds.contains(id), orElse: () => null);
      expect(foundOldFlashcardId, isNull);
    });

    test('When resetLearningProgress is true all imported flashcards should have its strength reseted', () async {
      var backupService = FlashcardBackupServiceTest(flashcards: [
        Flashcard(id: 10, term: 'term1', definition: 'definition1', lastSeenAt: DateTime.now(), strength: 2),
        Flashcard(id: 11, term: 'term2', definition: 'definition2', lastSeenAt: DateTime.now(), strength: 3),
        Flashcard(id: 12, term: 'term3', definition: 'definition3', lastSeenAt: DateTime.now(), strength: 5),
      ]);

      var importFlashcards = ImportFlashcardsUseCase(
          flashcardRepository: flashcardRepository,
          categoryRepository: categoryRepository,
          flashcardBackupService: backupService);

      await importFlashcards.call(resetFlashcadsStrength: true).last;

      var flashcards = await flashcardRepository.query();

      var strengths = flashcards.map((e) => e.strength);
      for (var strength in strengths) {
        expect(strength, 1);
      }
    });

    test('When importing flashcards... Existing flashcards (same term and definition) should be ignored', () async {
      var existingFlashcards = [
        Flashcard(term: 'term1', definition: 'definition1', lastSeenAt: DateTime.now(), strength: 2),
        Flashcard(term: 'term2', definition: 'definition2', lastSeenAt: DateTime.now(), strength: 3),
      ];

      for (var flashcard in existingFlashcards) {
        await flashcardRepository.save(flashcard);
      }

      var backupService = FlashcardBackupServiceTest(flashcards: [
        Flashcard(id: 10, term: 'term1', definition: 'definition1', lastSeenAt: DateTime.now(), strength: 2),
        Flashcard(id: 12, term: 'term3', definition: 'definition3', lastSeenAt: DateTime.now(), strength: 5),
        Flashcard(id: 12, term: 'term2', definition: 'definition1', lastSeenAt: DateTime.now(), strength: 5),
      ]);

      var importFlashcards = ImportFlashcardsUseCase(
          flashcardRepository: flashcardRepository,
          categoryRepository: categoryRepository,
          flashcardBackupService: backupService);

      await importFlashcards.call(resetFlashcadsStrength: false).last;

      var flashcards = await flashcardRepository.query();
      expect(flashcards.length, 4);
    });

    test(
        'When importing flashcards... Existing categories (same name) should be reused avoiding creating duplicated categories',
        () async {
      var existingCategory = Category(name: "existingCategory");
      existingCategory = await categoryRepository.save(existingCategory);

      var backupService = FlashcardBackupServiceTest(flashcards: [
        Flashcard(
            id: 10,
            term: 'term1',
            definition: 'definition1',
            lastSeenAt: DateTime.now(),
            strength: 2,
            category: Category(id: 100, name: "existingCategory")),
      ]);

      var importFlashcards = ImportFlashcardsUseCase(
          flashcardRepository: flashcardRepository,
          categoryRepository: categoryRepository,
          flashcardBackupService: backupService);

      await importFlashcards.call(resetFlashcadsStrength: false).last;

      var flashcards = await flashcardRepository.query();
      var foundFlashcard = flashcards.firstWhere((element) =>
          element.term == 'term1' &&
          element.definition == 'definition1' &&
          element.category?.name == 'existingCategory');

      expect(foundFlashcard, isNotNull);
      expect(foundFlashcard.category!.id, existingCategory.id);

      var categories = await categoryRepository.findAll();
      expect(categories.length, 1);
    });
  });
}
