part of 'file_backup_service.dart';

class SharedDataReceiverToBackupAdapter implements IFlashcardBackupService {
  SharedDataReceiver _dataReceiver;

  SharedDataReceiverToBackupAdapter({
    required SharedDataReceiver dataReceiver,
  }) : _dataReceiver = dataReceiver;

  @override
  Future<void> backup(List<Flashcard> flashcards) {
    throw UnimplementedError();
  }

  @override
  Future<List<Flashcard>> restore() async {
    try {
      var lines = await _dataReceiver.receiveFileLines();
      var flashcards = await _FlashcardJsonMapper.fromJsonLines(lines);
      return flashcards;
    } on PlatformException catch (platformException) {
      throw handlerPlatformException(platformException);
    } on Failure catch (_) {
      rethrow;
    } on Exception catch (e) {
      // when compute fails it throws an Exception containing the error type in its message
      if (e.toString().contains(CorruptedDataFailure().runtimeType.toString())) {
        throw CorruptedDataFailure();
      }
      rethrow;
    }
  }
}
