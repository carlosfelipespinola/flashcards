
class CategorySchema {
  static String tableName = 'category';
  static String id = 'category_id';
  static String name = 'category_name';

  static String get createTable => 'CREATE TABLE $tableName('
    ' $id INTEGER PRIMARY KEY NOT NULL AUTOINCREMENT,'
    ' $name TEXT NOT NULL'
  ');';
}