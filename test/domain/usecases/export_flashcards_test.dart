import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/interfaces/flashcard_backup_service.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flashcards/domain/usecases/export_flashcards.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FlashcardBackupServiceTest implements IFlashcardBackupService {
  List<Flashcard> _flashcards = [];

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
  var backupService = FlashcardBackupServiceTest();
  var exportFlashcards =
      ExportFlashcardsUseCase(flashcardRepository: flashcardRepository, flashcardBackupService: backupService);

  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  test('Export flashcards use case should export all flashcards', () async {
    var flashcardsToExport = [
      Flashcard(term: 'term1', definition: 'definition1', lastSeenAt: DateTime.now(), strength: 2),
      Flashcard(term: 'term2', definition: 'definition2', lastSeenAt: DateTime.now(), strength: 2),
      LowPriorityFlashcard(
          lowPriorityStrength: 2,
          base: Flashcard(term: 'term3', definition: 'definition3', lastSeenAt: DateTime.now(), strength: 2),
          lowPriorityInfo: LowPriorityInfo(
              enterDateTime: DateTime.now().subtract(Duration(hours: 8)), duration: Duration(hours: 4))),
      Flashcard(term: 'term4', definition: 'definition4', lastSeenAt: DateTime.now(), strength: 2),
    ];

    for (var flashcard in flashcardsToExport) {
      await flashcardRepository.save(flashcard);
    }

    await exportFlashcards.call();

    var restoredFlashcards = await backupService.restore();
    expect(
      flashcardsToExport.length,
      restoredFlashcards.length,
    );
  });
}
