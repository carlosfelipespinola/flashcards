import 'flashcard.schema.dart';
import 'category.schema.dart';


/// migrations cannot be removed or changed.
/// 
/// any change to the database should create a new migration and
/// the version of the new migration must be the version of the last plus 1
class Migrations {
  static List<Migration> get items => [
    Migration(
      version: 1,
      scripts: [
        'CREATE TABLE ${FlashcardSchema.tableName}('
          ' ${FlashcardSchema.id} INTEGER PRIMARY KEY NOT NULL,'
          ' ${FlashcardSchema.term} TEXT NOT NULL,'
          ' ${FlashcardSchema.definition} TEXT NOT NULL,'
          ' ${FlashcardSchema.lastSeenAt} DATETIME NOT NULL,'
          ' ${FlashcardSchema.strength} INTEGER NOT NULL,'
          ' ${FlashcardSchema.category} INTEGER,'
          ' CONSTRAINT fk_flashcard_category FOREIGN KEY(${FlashcardSchema.category}) REFERENCES ${CategorySchema.tableName}(${CategorySchema.id}) ON DELETE SET NULL'
        ');',

        'CREATE TABLE ${CategorySchema.tableName}('
          ' ${CategorySchema.id} INTEGER PRIMARY KEY NOT NULL,'
          ' ${CategorySchema.name} TEXT NOT NULL'
        ');'
      ]
    ),
    Migration(
      version: 2,
      scripts: [
        'ALTER TABLE ${FlashcardSchema.tableName} ADD COLUMN ${FlashcardSchema.enteredLowAt} DATETIME;',
        'ALTER TABLE ${FlashcardSchema.tableName} ADD COLUMN ${FlashcardSchema.exitsLowAt} DATETIME;'
      ]
    )
  ];

  static int get lastVersion {
    final sortedMigrations = items.toList()..sort((a, b) => a.version.compareTo(b.version));
    return sortedMigrations.last.version;
  }
}

class Migration {
  int version;
  List<String> scripts;
  Migration({
    required this.version,
    required this.scripts,
  });
}
