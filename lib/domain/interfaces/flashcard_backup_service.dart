import '../models/fashcard.dart';

abstract class IFlashcardBackupService {
  Future<void> backup(List<Flashcard> flashcards);
  Future<List<Flashcard>> restore();
}
