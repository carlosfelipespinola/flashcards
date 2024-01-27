// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard_backup_service.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class ImportFlashcardsProgressTracker {
  int flashcardsToImportCount = 0;
  int importedFlashcardsCount = 0;
  int importFlashcardsErrors = 0;
  int duplicatedFlashcards = 0;

  int get currentFlashcard => (importedFlashcardsCount + importFlashcardsErrors + duplicatedFlashcards);

  double get progress {
    if (flashcardsToImportCount == 0) return 0;

    return ((importedFlashcardsCount + importFlashcardsErrors + duplicatedFlashcards) / flashcardsToImportCount);
  }
}

class ImportFlashcardsUseCase {
  final IFlashcardRepository flashcardRepository;
  final ICategoryRepository categoryRepository;
  final IFlashcardBackupService flashcardBackupService;

  Map<String, Category> _categories = {};
  late ImportFlashcardsProgressTracker _progressTracker;

  ImportFlashcardsUseCase(
      {required this.flashcardRepository, required this.categoryRepository, required this.flashcardBackupService});

  /// may throw UserCanceledActionFailure, CorruptedDataFailure, InvalidBackupLocationFailure or Failure
  Stream<ImportFlashcardsProgressTracker> call({required bool resetFlashcadsStrength}) async* {
    _progressTracker = ImportFlashcardsProgressTracker();
    yield _progressTracker;

    var flashcards = await _restoreFlashcards();
    yield _progressTracker;

    await _cacheCategoriesFromDatabase();

    for (var newFlashcard in flashcards) {
      await _importFlashcard(newFlashcard, resetFlashcadsStrength);
      yield _progressTracker;
    }
  }

  Future<void> _cacheCategoriesFromDatabase() async {
    _categories = Map.fromIterable((await categoryRepository.findAll()),
        key: ((e) => (e as Category).name), value: (e) => (e as Category));
  }

  Future<List<Flashcard>> _restoreFlashcards() async {
    var flashcards = await flashcardBackupService.restore();
    _progressTracker.flashcardsToImportCount = flashcards.length;
    return flashcards;
  }

  Future<void> _importFlashcard(Flashcard flashcard, bool resetStrength) async {
    try {
      var flashcardExists = await flashcardRepository.exists(term: flashcard.term, definition: flashcard.definition);

      if (flashcardExists) {
        _progressTracker.duplicatedFlashcards += 1;
        return;
      }

      if (!flashcard.isValid()) throw Failure();

      flashcard.id = null;

      if (resetStrength) flashcard.resetStrength();

      flashcard.category = await _createOrFindCategoryFor(flashcard);

      await flashcardRepository.save(flashcard);
      _progressTracker.importedFlashcardsCount += 1;
    } catch (_) {
      _progressTracker.importFlashcardsErrors += 1;
    }
  }

  Future<Category?> _createOrFindCategoryFor(Flashcard flashcard) async {
    if (flashcard.category == null) return null;

    var foundCategory = _categories[flashcard.category!.name];

    if (foundCategory == null) {
      flashcard.category?.id = null;
      var createdCategory = await categoryRepository.save(flashcard.category!);
      _categories[createdCategory.name] = createdCategory;
      return createdCategory;
    }

    return foundCategory;
  }
}
