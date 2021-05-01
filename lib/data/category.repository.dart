
import 'package:flashcards/data/category.mapper.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/services/database.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository implements ICategoryRepository {

  DatabaseProvider databaseProvider;

  CategoryRepository({required this.databaseProvider});

  Future<DatabaseExecutor> get dbe async {
    return await databaseProvider.db;
  }

  @override
  Future<Category> delete(Category category) async {
    try {
      int deletedRows = await (await dbe).delete(
        CategorySchema.tableName,
        where: '${CategorySchema.id} = ?',
        whereArgs: [category.id]
      );
      if (deletedRows == 0) {
        throw Failure();
      }
      return category;
    } catch (_) {
      throw Failure();
    }
  }

  @override
  Future<List<Category>> findAll({bool countFlashcards = false}) async {
    try {
      if (!countFlashcards) {
        final categoriesMap = await (await dbe).query(CategorySchema.tableName);
        return categoriesMap.map((map) => CategoryMapper.fromMap(map)).toList();
      } else {
        final categoriesMap = await (await dbe).rawQuery(
          'SELECT *, IFNULL(COUNT(${FlashcardSchema.id}), 0) as ${CategorySchema.flashcardsCount} '
          'FROM ${CategorySchema.tableName} '
          'LEFT JOIN ${FlashcardSchema.tableName} on ${CategorySchema.id} = ${FlashcardSchema.category} '
          'GROUP BY ${CategorySchema.id}'
          
        );
        return categoriesMap.map((map) => CategoryMapper.fromMap(map)).toList();
      }
    } catch (_) {
      print(_);
      throw Failure();
    }
  }

  @override
  Future<Category> save(Category category) async {
    try {
      bool shouldCreate = category.id == null;
      return shouldCreate ? await _insertCategory(category) :  await _updateCategory(category);
    } catch (_) {
      throw Failure();
    }
  }

  Future<Category> _insertCategory(Category category) async {
    try {
      final id = await (await dbe).insert(
        CategorySchema.tableName,
        CategoryMapper.toMap(category),
        conflictAlgorithm: ConflictAlgorithm.abort
      );
      if (id == 0) {
        throw Failure();
      }
      category.id = id;
      return category;
    } catch (_) {
      throw Failure();
    }
  }

  Future<Category> _updateCategory(Category category) async {
    try {
      int rowsUpdated = await (await dbe).update(
        CategorySchema.tableName,
        CategoryMapper.toMap(category),
        where: '${CategorySchema.id} = ?',
        whereArgs: [category.id]
      );
      if (rowsUpdated == 0) {
        throw Failure();
      }
      return category;
    } catch (_) {
      throw Failure();
    }
  }

}