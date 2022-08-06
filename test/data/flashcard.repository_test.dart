import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/data/flashcard.mapper.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flutter_test/flutter_test.dart';
class FlashcardTestRepository extends FlashcardRepository {
  FlashcardTestRepository({required DatabaseProvider databaseProvider}) : super(databaseProvider: databaseProvider);

  Future<Flashcard> findById(int id) async {
    final executor = await dbe;
    final result = await executor.query(FlashcardSchema.tableName, where: '${FlashcardSchema.id} = ?', whereArgs: [id]);
    final map = result.first;
    return FlashcardMapper.fromMap(map);
  }

}

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var database = await dbProvider.db;
  var flashcardRepository = FlashcardTestRepository(databaseProvider: dbProvider);

  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  test('save flashcard must work ...', () async {
    var flashcard = Flashcard(
      term: 'term',
      definition: 'definition',
      lastSeenAt: DateTime.now(),
      strength: 2
    );
    flashcard = await flashcardRepository.save(flashcard);
    final foundFlashcard = await flashcardRepository.findById(flashcard.id!);
    expect(flashcard.category, foundFlashcard.category);
    expect(flashcard.id, foundFlashcard.id);
    expect(flashcard.definition, foundFlashcard.definition);
    expect(flashcard.term, foundFlashcard.term);
    expect(flashcard.lastSeenAt, foundFlashcard.lastSeenAt);
    expect(flashcard.strength, foundFlashcard.strength);
    expect(flashcard, isNot(isA<LowPriorityFlashcard>()));
    expect(foundFlashcard, isNot(isA<LowPriorityFlashcard>()));
    expect(flashcard, isA<Flashcard>());
    expect(foundFlashcard, isA<Flashcard>());
  });

  test('save without category must set category null ...', () async {
    var flashcard = Flashcard(
      term: 'term',
      definition: 'definition',
      lastSeenAt: DateTime.now(),
      strength: 2
    );
    flashcard = await flashcardRepository.save(flashcard);
    final foundFlashcard = await flashcardRepository.findById(flashcard.id!);
    expect(flashcard.category, null);
    expect(foundFlashcard.category, null);
  });

  test('save low priority flashcard must work...', () async {
    Flashcard flashcard = LowPriorityFlashcard(
      lowPriorityStrength: 2,
      base: Flashcard(
        term: 'term',
        definition: 'definition',
        lastSeenAt: DateTime.now(),
        strength: 2
      ),
      lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now(), duration: Duration(hours: 4))
    );
    flashcard = await flashcardRepository.save(flashcard);
    final foundFlashcard = await flashcardRepository.findById(flashcard.id!);
    expect(flashcard.category, foundFlashcard.category);
    expect(flashcard.id, foundFlashcard.id);
    expect(flashcard.definition, foundFlashcard.definition);
    expect(flashcard.term, foundFlashcard.term);
    expect(flashcard.lastSeenAt, foundFlashcard.lastSeenAt);
    expect(flashcard.strength, foundFlashcard.strength);
    expect(flashcard, isA<LowPriorityFlashcard>());
    expect(foundFlashcard, isA<LowPriorityFlashcard>());
    expect(
      (foundFlashcard as LowPriorityFlashcard).lowPriorityInfo.enterDateTime,
      (flashcard as LowPriorityFlashcard).lowPriorityInfo.enterDateTime
    );
    expect(
      foundFlashcard.lowPriorityInfo.expiresAt,
      flashcard.lowPriorityInfo.expiresAt
    );
  });

  test('update flashcard into low priority flashcard must work ...', () async {
    var flashcard = Flashcard(
      term: 'term',
      definition: 'definition',
      lastSeenAt: DateTime.now(),
      strength: 2
    );
    flashcard = await flashcardRepository.save(flashcard);
    Flashcard lowPriorityFlashcard = LowPriorityFlashcard(
      lowPriorityStrength: 2,
      base: flashcard,
      lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now(), duration: Duration(hours: 4))
    );
    await flashcardRepository.save(lowPriorityFlashcard);
    final foundLowPriorityFlashcard = await flashcardRepository.findById(flashcard.id!);
    expect(flashcard.category, foundLowPriorityFlashcard.category);
    expect(flashcard.id, foundLowPriorityFlashcard.id);
    expect(flashcard.definition, foundLowPriorityFlashcard.definition);
    expect(flashcard.term, foundLowPriorityFlashcard.term);
    expect(flashcard.lastSeenAt, foundLowPriorityFlashcard.lastSeenAt);
    expect(flashcard.strength, foundLowPriorityFlashcard.strength);
    expect(foundLowPriorityFlashcard, isA<LowPriorityFlashcard>());
  });

  test('update low priority flashcard into flashcard must work ...', () async {
    Flashcard lowPriorityFlashcard = LowPriorityFlashcard(
      lowPriorityStrength: 2,
      base: Flashcard(
        term: 'term',
        definition: 'definition',
        lastSeenAt: DateTime.now(),
        strength: 2
      ),
      lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now(), duration: Duration(hours: 4))
    );
    lowPriorityFlashcard = await flashcardRepository.save(lowPriorityFlashcard);
    await flashcardRepository.save((lowPriorityFlashcard as LowPriorityFlashcard).toNonLowPriority());
    final foundFlashcard = await flashcardRepository.findById(lowPriorityFlashcard.id!);
    expect(lowPriorityFlashcard.category, foundFlashcard.category);
    expect(lowPriorityFlashcard.id, foundFlashcard.id);
    expect(lowPriorityFlashcard.definition, foundFlashcard.definition);
    expect(lowPriorityFlashcard.term, foundFlashcard.term);
    expect(lowPriorityFlashcard.lastSeenAt, foundFlashcard.lastSeenAt);
    expect(lowPriorityFlashcard.strength, foundFlashcard.strength);
    expect(foundFlashcard, isA<Flashcard>());
    expect(foundFlashcard, isNot(isA<LowPriorityFlashcard>()));
  });

  test('save non low priority flashcards must set null low priority info null ...', () async {
    var flashcard = Flashcard(
      term: 'term',
      definition: 'definition',
      lastSeenAt: DateTime.now(),
      strength: 2
    );
    flashcard = await flashcardRepository.save(flashcard);
    final foundFlashcard = await flashcardRepository.findById(flashcard.id!);
    expect(flashcard.category, null);
    expect(foundFlashcard.category, null);
  });

  test('expired low priority flashcards should be returned as flashcard ...', () async {
    Flashcard lowPriorityFlashcard = LowPriorityFlashcard(
      lowPriorityStrength: 2,
      base: Flashcard(
        term: 'term',
        definition: 'definition',
        lastSeenAt: DateTime.now(),
        strength: 2
      ),
      lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now().subtract(Duration(hours: 8)), duration: Duration(hours: 4))
    );
    lowPriorityFlashcard = await flashcardRepository.save(lowPriorityFlashcard);
    final foundFlashcard = await flashcardRepository.findById(lowPriorityFlashcard.id!);
    expect(foundFlashcard, isA<Flashcard>());
    expect(foundFlashcard, isNot(isA<LowPriorityFlashcard>()));
  });

}