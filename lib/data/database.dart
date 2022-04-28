import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'flashcard.schema.dart';
import 'category.schema.dart';

part 'database_migrations.dart';

class DatabaseProvider {
  bool _test;
  bool _initDbFailed = false;
  Future<Database>? _databaseFuture;

  DatabaseProvider({
    required bool test,
  }) : _test = test;

  Future<Database> get db {
    if (_initDbFailed) {
      _databaseFuture = null;
      _initDbFailed = false;
    }
    _databaseFuture ??= _initDb();
    return _databaseFuture!;
  }

  Future<_SharedPreferencesDatabase> get sharedPreferences async {
    return _SharedPreferencesDatabase(database: await db);
  }

  Future<Database> _initDb() async {
    try {
      return _test ? await _initTestDb() : await _initProductionDb();
    } catch (error) {
      _initDbFailed = true;
      throw error;
    } 
  }

  Future<Database> _initTestDb() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    return databaseFactory.openDatabase(
      inMemoryDatabasePath, 
      options: OpenDatabaseOptions(
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: Migrations.lastVersion,
      )
    );
  }

  Future<Database> _initProductionDb() async {
    final path = await databasePath;
    await _makeSureDatabasesPathExists(dirname(path));
    final database = await openDatabase(
      path,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: Migrations.lastVersion,
    );
    return database;
  }

  Future<String> get databasePath async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'app_main_database.db');
    return path;
  }

  Future<void> _makeSureDatabasesPathExists(String databasesPath) async {
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}
  }

  Future<void> _onConfigure(Database database) async {
    await database.execute('PRAGMA foreign_keys=ON');
  }

  Future<void> _onCreate(Database database, int version) async {
    var batch = database.batch();
    _executeMigrations(Migrations.items, batch);
    await batch.commit();
  }

  Future<void> _onUpgrade(Database database, int oldVersion, int newVersion) async {
    var batch = database.batch();
    bool migrationFilter(Migration migration) => migration.version > oldVersion && migration.version <= newVersion;
    final migrations = Migrations.items.where(migrationFilter).toList();
    _executeMigrations(migrations, batch);
    await batch.commit(continueOnError: true);
  }

  void _executeMigrations(List<Migration> migrations, Batch batch) {
    for (var migration in migrations) {
      for (var script in migration.scripts) {
        batch.execute(script);
      }
    }
  }
  
}

class _SharedPreferencesDatabase {
  final Database database;

  _SharedPreferencesDatabase({
    required this.database,
  });

  Future<void> save(String key, String value) async {
    final count = await database.insert(
      SharedPreferencesSchema.tableName,
      _SharedPreferencesMapper.toMap(_SharedPreferences(key: key, value: value)),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
    if (count == 0) {
      throw Exception('no items were updated');
    }
  }

  Future<String?> load(String key) async {
    final maps = await database.query(
      SharedPreferencesSchema.tableName,
      where: '${SharedPreferencesSchema.key} = ?',
      whereArgs: [key]
    );
    if (maps.isEmpty) {
      return null;
    }
    final map = maps.first;
    final _SharedPreferences preferences = _SharedPreferencesMapper.fromMap(map);
    return preferences.value;
  }
}

class _SharedPreferencesMapper {
  static _SharedPreferences fromMap(Map<String, dynamic> map) {
    return _SharedPreferences(
      key: map[SharedPreferencesSchema.key],
      value: map[SharedPreferencesSchema.value]
    );
  }

  static Map<String, dynamic> toMap(_SharedPreferences sharedPreferences) {
    return <String, dynamic>{
      SharedPreferencesSchema.key: sharedPreferences.key,
      SharedPreferencesSchema.value: sharedPreferences.value
    };
  }
}

@visibleForTesting
class SharedPreferencesSchema {
  static String tableName = 'preferences';
  static String key = 'name';
  static String value = 'value';
}

class _SharedPreferences {
  final String key;
  final String value;

  _SharedPreferences({
    required this.key,
    required this.value,
  });
}
