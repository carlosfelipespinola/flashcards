import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard_backup_service.dart';

class ExportFlashcardsUseCase {
  final IFlashcardRepository flashcardRepository;
  final IFlashcardBackupService flashcardBackupService;

  ExportFlashcardsUseCase({required this.flashcardRepository, required this.flashcardBackupService});

  /// may throw UserCanceledActionFailure, CorruptedDataFailure, InvalidBackupLocationFailure or Failure
  Future<void> call() async {
    var flashcards = await flashcardRepository.query();

    await flashcardBackupService.backup(flashcards);
  }
}
