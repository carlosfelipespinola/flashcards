part of 'file_backup_service.dart';

class _AndroidFlashcardsJsonlFileBackupService implements FileBackupService {
  static const platform = MethodChannel(ANDROID_METHOD_CHANNEL_NAME);

  _AndroidFlashcardsJsonlFileBackupService();

  @override
  Future<void> backup(List<Flashcard> flashcards) async {
    try {
      var jsonLines = await _FlashcardJsonMapper.toJsonLines(flashcards);
      await platform.invokeMethod<dynamic>('backupData', <String, dynamic>{"fileLines": jsonLines});
    } on PlatformException catch (platformException) {
      throw _handlerPlatformException(platformException);
    } on Failure catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> restore() async {
    try {
      var jsonLines = await platform.invokeMethod<List>('restoreData');
      return await _FlashcardJsonMapper.fromJsonLines(jsonLines!);
    } on PlatformException catch (platformException) {
      throw _handlerPlatformException(platformException);
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

  Failure _handlerPlatformException(PlatformException exception) {
    switch (exception.code) {
      case AndroidPlatformErrorCodes.USER_CANCELED_ACTION_ERROR:
        return UserCanceledActionFailure();
      case AndroidPlatformErrorCodes.FILE_NOT_FOUND_ERROR:
        return InvalidBackupLocationFailure();
      case AndroidPlatformErrorCodes.UNSUPPORTED_FILE_ERROR:
        return UnsupportedFileFormatFailure();
      case AndroidPlatformErrorCodes.UNKNOWN_ERROR:
      case AndroidPlatformErrorCodes.IO_ERROR:
        return Failure();
      default:
        throw exception;
    }
  }
}
