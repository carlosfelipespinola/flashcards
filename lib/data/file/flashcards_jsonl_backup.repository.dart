// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flashcards/data/file/flashcard_json.mapper.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/interfaces/flashcard_backup_service.dart';

class FlashcardsJsonlBackupRepository implements IFlashcardBackupService {
  static const platform = MethodChannel('carlosfelipe.dev/flashcards');

  FlashcardsJsonlBackupRepository();

  /// may throw Failure
  @override
  Future<void> backup(List<Flashcard> flashcards) async {
    try {
      var jsonLines = await compute<List<Flashcard>, List<String>>((x) async {
        return x.map((e) => FlashcardJsonMapper.toJson(e)).toList();
      }, flashcards);
      await platform.invokeMethod<dynamic>('backupData', <String, dynamic>{"fileLines": jsonLines});
    } catch (e) {
      throw Failure();
    }
  }

  /// may throw Failure
  @override
  Future<List<Flashcard>> restore() async {
    try {
      var result = await platform.invokeMethod<List>('restoreData');
      var flashcards = await compute<List, List<Flashcard>>((x) async {
        return x.map<Flashcard>((e) => FlashcardJsonMapper.fromJson(e as String)).toList();
      }, result!);
      return flashcards;
    } on Failure catch (_) {
      rethrow;
    } catch (e) {
      throw Failure();
    }
  }
}
