import 'dart:convert';
import 'dart:io';

import 'package:flashcards/domain/interfaces/flashcard_backup_service.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/services/platform_utils.dart';
import 'package:flashcards/services/shared_data_receiver/shared_data_receiver.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';

part '_ios_json_file_backup_service_impl.dart';
part '_flashcard_json.mapper.dart';
part '_android_jsonl_file_backup_service_impl.dart';
part 'shared_data_receiver_to_backup_adapter.dart';

abstract class FileBackupService implements IFlashcardBackupService {
  factory FileBackupService.create() {
    if (Platform.isAndroid) {
      return _AndroidFlashcardsJsonlFileBackupService();
    } else if (Platform.isIOS) {
      return _IosJsonlBackupService();
    } else {
      throw UnsupportedError("Service unsupported on platform ${Platform.operatingSystem}");
    }
  }
}
