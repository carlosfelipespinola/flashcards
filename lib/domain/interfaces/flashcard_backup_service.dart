import '../models/fashcard.dart';

abstract class IFlashcardBackupService {
  /// may throw UserCanceledActionFailure, CorruptedDataFailure, InvalidBackupLocationFailure or Failure
  Future<void> backup(List<Flashcard> flashcards);

  /// may throw UserCanceledActionFailure, CorruptedDataFailure, InvalidBackupLocationFailure or Failure
  Future<List<Flashcard>> restore();
}
