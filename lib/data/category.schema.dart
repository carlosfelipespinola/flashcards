
class CategorySchema {
  static String tableName = 'category';
  static String id = 'id';
  static String name = 'name';

  static String get createTable => 'CREATE TABLE $tableName('
    ' $id INTEGER PRIMARY KEY NOT NULL,'
    ' $name TEXT NOT NULL'
  ');';
}