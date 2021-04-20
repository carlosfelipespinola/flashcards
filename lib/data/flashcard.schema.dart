
import 'package:flashcards/data/category.schema.dart';

class FlashcardSchema {
  static String tableName = 'flashcard';
  static String id = 'id';
  static String term = 'term';
  static String definition = 'definition';
  static String strength = 'strength';
  static String lastSeenAt = 'last_seen_at';
  static String category = 'category';

   static String get createTableSql => 'CREATE TABLE $tableName('
    ' $id INTEGER PRIMARY KEY NOT NULL,'
    ' $term TEXT NOT NULL,'
    ' $definition TEXT NOT NULL,'
    ' $lastSeenAt DATETIME NOT NULL,'
    ' $strength INTEGER NOT NULL,'
    ' $category INTEGER,'
    ' CONSTRAINT fk_flashcard_category FOREIGN KEY($category) REFERENCES ${CategorySchema.tableName}(${CategorySchema.id}) ON DELETE SET NULL'
  ');';
}