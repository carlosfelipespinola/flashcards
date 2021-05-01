
class CategorySchema {
  static String tableName = 'category';
  static String id = 'category_id';
  static String name = 'category_name';
  static String flashcardsCount = 'flashcards_count';

  static String get createTable => 'CREATE TABLE $tableName('
    ' $id INTEGER PRIMARY KEY NOT NULL,'
    ' $name TEXT NOT NULL'
  ');';
}