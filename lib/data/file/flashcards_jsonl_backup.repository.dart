// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flashcards/data/file/flashcard_json.mapper.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

import '../../domain/interfaces/flashcard_backup_service.dart';

class FlashcardsBackupServiceFactory {
  static IFlashcardBackupService createJsonlBackupService() {
    if (Platform.isAndroid) {
      return _AndroidFlashcardsJsonlBackupRepository();
    } else if (Platform.isIOS) {
      return _IosJsonlBackupService();
    } else {
      throw UnsupportedError("Service unsupported on platform ${Platform.operatingSystem}");
    }
  }
}

class _BackupRestoreErrorCodes {
  static const String UNKNOWN_ERROR_CODE = "unknown-error";
  static const String FILE_NOT_FOUND_ERROR_CODE = "file-not-found-error";
  static const String USER_CANCELED_ACTION_ERROR_CODE = "user-canceled-action-error";
  static const String IO_ERROR_CODE = "io-error";
}

class _AndroidFlashcardsJsonlBackupRepository implements IFlashcardBackupService {
  static const platform = MethodChannel('carlosfelipe.dev/flashcards');

  _AndroidFlashcardsJsonlBackupRepository();

  @override
  Future<void> backup(List<Flashcard> flashcards) async {
    try {
      var jsonLines = await compute<List<Flashcard>, List<String>>((x) {
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

class _IosJsonlBackupService implements IFlashcardBackupService {
  @override
  Future<void> backup(List<Flashcard> flashcards) {
    throw UnimplementedError();
  }

  @override
  Future<List<Flashcard>> restore() {
    throw UnimplementedError();
  }
}
