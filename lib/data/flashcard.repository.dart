
import 'package:flashcards/data/flashcard.mapper.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/sort.dart';
import 'package:sqflite/sqflite.dart';

class FlashcardRepository implements IFlashcardRepository {

  DatabaseExecutor get dbe => throw UnimplementedError();

  @override
  Future<Flashcard> delete(Flashcard flashcard) async {
    try {
      int deletedRows = await dbe.delete(
        FlashcardSchema.tableName,
        where: '${FlashcardSchema.id} = ?',
        whereArgs: [flashcard.id]
      );
      if (deletedRows == 0) {
        throw Failure();
      }
      return flashcard;
    } catch (_) {
      throw Failure();
    }
  }

  @override
  Future<List<Flashcard>> findAll() async {
    try {
      final flashcardsMap = await dbe.query(FlashcardSchema.tableName);
      return flashcardsMap.map((map) => FlashcardMapper.fromMap(map)).toList();
    } catch (_) {
      throw Failure();
    }
  }

  @override
  Future<List<Flashcard>> query({Category? category, List<Sort<FlashcardSortableFields>>? sortBy, int? limit, bool? randomize = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Flashcard> save(Flashcard flashcard) async {
    try {
      bool shouldCreate = flashcard.id == null;
      return shouldCreate ? await _insertFlashcard(flashcard) :  await _updateFlashcard(flashcard);
    } catch (_) {
      throw Failure();
    }
  }

  Future<Flashcard> _insertFlashcard(Flashcard flashcard) async {
    try {
      final id = await dbe.insert(
        FlashcardSchema.tableName,
        FlashcardMapper.toMap(flashcard),
        conflictAlgorithm: ConflictAlgorithm.abort
      );
      if (id == 0) {
        throw Failure();
      }
      flashcard.id = id;
      return flashcard;
    } catch (_) {
      throw Failure();
    }
  }

  Future<Flashcard> _updateFlashcard(Flashcard flashcard) async {
    try {
      int rowsUpdated = await dbe.update(
        FlashcardSchema.tableName,
        FlashcardMapper.toMap(flashcard),
        where: '${FlashcardSchema.id} = ?',
        whereArgs: [flashcard.id]
      );
      if (rowsUpdated == 0) {
        throw Failure();
      }
      return flashcard;
    } catch (_) {
      throw Failure();
    }
  }

}