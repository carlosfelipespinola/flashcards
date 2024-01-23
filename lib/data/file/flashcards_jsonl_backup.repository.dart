// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flashcards/data/file/flashcard_json.mapper.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/interfaces/flashcard_backup_service.dart';

class _BackupRestoreErrorCodes {
  static const String UNKNOWN_ERROR_CODE = "unknown-error";
  static const String FILE_NOT_FOUND_ERROR_CODE = "file-not-found-error";
  static const String USER_CANCELED_ACTION_ERROR_CODE = "user-canceled-action-error";
  static const String IO_ERROR_CODE = "io-error";
}

class FlashcardsJsonlBackupRepository implements IFlashcardBackupService {
  static const platform = MethodChannel('carlosfelipe.dev/flashcards');

  FlashcardsJsonlBackupRepository();

  @override
  Future<void> backup(List<Flashcard> flashcards) async {
    try {
      var jsonLines = await compute<List<Flashcard>, List<String>>((x) async {
        return x.map((e) => FlashcardJsonMapper.toJson(e)).toList();
      }, flashcards);
      await platform.invokeMethod<dynamic>('backupData', <String, dynamic>{"fileLines": jsonLines});
    } on PlatformException catch (platformException) {
      var failure = _handlerPlatformException(platformException);
      throw failure;
    } on Failure catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> restore() async {
    try {
      var result = await platform.invokeMethod<List>('restoreData');
      var flashcards = await compute<List, List<Flashcard>>((x) async {
        return x.map<Flashcard>((e) => FlashcardJsonMapper.fromJson(e as String)).toList();
      }, result!);
      return flashcards;
    } on PlatformException catch (platformException) {
      var failure = _handlerPlatformException(platformException);
      throw failure;
    } on Failure catch (_) {
      rethrow;
    }
  }

  Failure _handlerPlatformException(PlatformException exception) {
    switch (exception.code) {
      case _BackupRestoreErrorCodes.USER_CANCELED_ACTION_ERROR_CODE:
        return UserCanceledActionFailure();
      case _BackupRestoreErrorCodes.FILE_NOT_FOUND_ERROR_CODE:
        return InvalidBackupLocationFailure();
      case _BackupRestoreErrorCodes.UNKNOWN_ERROR_CODE:
      case _BackupRestoreErrorCodes.IO_ERROR_CODE:
        return Failure();
      default:
        throw exception;
    }
  }
}
