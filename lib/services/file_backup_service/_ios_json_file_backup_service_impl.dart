part of 'file_backup_service.dart';

class _IosJsonlBackupService implements FileBackupService {
  @override
  Future<void> backup(List<Flashcard> flashcards) {
    throw UnimplementedError();
  }

  @override
  Future<List<Flashcard>> restore() {
    throw UnimplementedError();
  }
}
