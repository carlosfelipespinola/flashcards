
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.mapper.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_filters.dart';
import 'package:flashcards/domain/models/flashcard_sortable_fields.dart';
import 'package:flashcards/domain/models/sort.dart';
import 'package:flashcards/data/database.dart';
import 'package:sqflite/sqflite.dart';

class FlashcardRepository implements IFlashcardRepository {

  DatabaseProvider databaseProvider;

  FlashcardRepository({required this.databaseProvider});  

  Future<DatabaseExecutor> get dbe async {
    return await databaseProvider.db;
  }

  @override
  Future<Flashcard> delete(Flashcard flashcard) async {
    try {
      int deletedRows = await (await dbe).delete(
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
  Future<List<Flashcard>> query({
    List<FlashcardFilter> filters = const [],
    List<Sort<FlashcardSortableFields>>? sortBy,
    int? limit,
  }) async {
    var query = _findAllFlashcardsQuery;
    final arguments = [];
    
    for (final filter in filters) {
      if (filter is FlashcardCategoryFilter) {
        if (filter.category == null) {
          query += ' AND ${CategorySchema.id} IS NULL';
        } else {
          query += ' AND ${CategorySchema.id} = ${filter.category!.id}';
        }
      }
      if (filter is FlashcardSearchFilter) {
        final searchTerm = filter.search;
        query += ' AND ('
          '${FlashcardSchema.term} LIKE ?'
          ' OR '
          '${FlashcardSchema.definition} LIKE ?'
        ')';
        arguments.addAll(["%$searchTerm%", "%$searchTerm%"]);
      }
      if (filter is OnlyLowPriorityFlashcardsFilter) {
        query += ' AND ('
          'datetime(${FlashcardSchema.exitsLowAt}) > datetime(\'now\', \'localtime\')'
          ' AND '
          'datetime(${FlashcardSchema.enteredLowAt}) < datetime(\'now\', \'localtime\')'
        ')';
      }
      if (filter is ExceptLowPriorityFlashcardsFilter) {
        query += ' AND ('
          'datetime(${FlashcardSchema.exitsLowAt}) <= datetime(\'now\', \'localtime\')'
          ' OR '
          'datetime(${FlashcardSchema.enteredLowAt}) > datetime(\'now\', \'localtime\')'
          ' OR '
          '${FlashcardSchema.exitsLowAt} IS NULL'
          ' OR '
          '${FlashcardSchema.enteredLowAt} IS NULL'
        ')';
      }
    }
    
    if (sortBy != null && sortBy.length > 0) {
      query = _concatOrderBy(query, sortBy);
    }
    if (limit != null) {
      query += ' LIMIT $limit';
    }
    final rawFlashcards = await (await dbe).rawQuery(query, arguments);
    return rawFlashcards.map((map) => FlashcardMapper.fromMap(map)).toList();
  }

  String get _findAllFlashcardsQuery {
    return 'SELECT * FROM ${FlashcardSchema.tableName}'
      ' LEFT JOIN ${CategorySchema.tableName}'
      ' ON ${FlashcardSchema.category} = ${CategorySchema.id}'
      ' WHERE 1'
    ;
  }

  String _concatOrderBy(String query, List<Sort<FlashcardSortableFields>> sortBy) {
    query += ' ORDER BY ${sortBy.map((sort) => FlashcardMapper.mapSortToSql(sort)).join(", ")}';
    return query;
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
      final id = await (await dbe).insert(
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
      int rowsUpdated = await (await dbe).update(
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