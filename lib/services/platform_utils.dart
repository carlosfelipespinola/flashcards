import 'package:flashcards/domain/models/failure.dart';
import 'package:flutter/services.dart';

const ANDROID_METHOD_CHANNEL_NAME = "carlosfelipe.dev/flashcards";
const ANDROID_EVENT_CHANNEL_NAME = "carlosfelipe.dev/flashcards/events";

abstract class AndroidPlatformErrorCodes {
  static const String UNKNOWN_ERROR = "unknown-error";
  static const String FILE_NOT_FOUND_ERROR = "file-not-found-error";
  static const String USER_CANCELED_ACTION_ERROR = "user-canceled-action-error";
  static const String IO_ERROR = "io-error";
  static const String UNSUPPORTED_FILE_ERROR = "unsupported-file-error";
}

abstract class AndroidEventChannelEventsCodes {
  static const String INTENT_WITH_IMPORTABLE_DATA = "intent-with-importable-data";
}

Failure handlerPlatformException(PlatformException exception) {
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
