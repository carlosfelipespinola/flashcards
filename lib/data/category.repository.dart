
import 'package:flashcards/data/category.mapper.dart';
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository implements ICategoryRepository {

  DatabaseExecutor get dbe => throw UnimplementedError();

  @override
  Future<Category> delete(Category category) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> findAll() {
    throw UnimplementedError();
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
      final id = await dbe.insert(
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
      int rowsUpdated = await dbe.update(
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