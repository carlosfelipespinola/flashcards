import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/data/flashcard.mapper.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flashcards/domain/usecases/answer_flashcard.dart';
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
  var answerFlashcardUseCase = AnswerFlashcard(flashcardRepository: flashcardRepository);
  
  tearDown(() async {
    await database.delete(CategorySchema.tableName);
    await database.delete(FlashcardSchema.tableName);
  });

  group('Answer flashcards tests...', () {

    group('when answering correctly...', () {
      test('a non low priority flashcard should be marked as low priority and its lowPriorityStrength must be equals to its strength', () async {
        var flashcard = Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 2
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard, answeredCorrectly: true);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer, isA<LowPriorityFlashcard>());
        expect(foundFlashcard, isA<LowPriorityFlashcard>());

        expect((flashcardAfterAnswer as LowPriorityFlashcard).isStillLowPriority, true);
        expect((foundFlashcard as LowPriorityFlashcard).isStillLowPriority, true);

        expect(flashcardAfterAnswer.lowPriorityStrength, flashcardAfterAnswer.strength);
        expect(foundFlashcard.lowPriorityStrength, foundFlashcard.strength);
        // expect(flashcardAfterAnswer.category, foundFlashcard.category);
        // expect(flashcardAfterAnswer.definition, foundFlashcard.definition);
        // expect(flashcardAfterAnswer.term, foundFlashcard.term);
        // expect(flashcardAfterAnswer.strength, foundFlashcard.strength);
        // expect(flashcardAfterAnswer.id, foundFlashcard.id);
        // expect(flashcardAfterAnswer.lastSeenAt.toIso8601String(), foundFlashcard.lastSeenAt.toIso8601String());
        // expect(flashcardAfterAnswer.lowPriorityInfo.duration, foundFlashcard.lowPriorityInfo.duration);
        // expect(flashcardAfterAnswer.lowPriorityInfo.enterDateTime, foundFlashcard.lowPriorityInfo.enterDateTime);
      });

      test('a non low priority flashcard should have its strength increased', () async {
        var flashcard = Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 2
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: true);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer.strength, greaterThan(flashcard.strength));
        expect(flashcardAfterAnswer.strength, foundFlashcard.strength);
      });

      test('a low priority flashcard should not have its strength increased', () async {
        Flashcard flashcard = LowPriorityFlashcard(
          lowPriorityStrength: 2,
            base: Flashcard(
            term: 'term',
            definition: 'definition',
            lastSeenAt: DateTime.now(),
            strength: 2
          ),
          lowPriorityInfo: LowPriorityInfo(
            duration: Duration(hours: 4),
            enterDateTime: DateTime.now()
          )
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: true);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer.strength, flashcard.strength);
        expect(flashcardAfterAnswer.strength, foundFlashcard.strength);
      });

      test('a low priority flashcard should have its lowPriorityStrength increased', () async {
        final flashcard = LowPriorityFlashcard(
          lowPriorityStrength: 2,
            base: Flashcard(
            term: 'term',
            definition: 'definition',
            lastSeenAt: DateTime.now(),
            strength: 2
          ),
          lowPriorityInfo: LowPriorityInfo(
            duration: Duration(hours: 4),
            enterDateTime: DateTime.now()
          )
        );
        await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: true) as LowPriorityFlashcard;
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!) as LowPriorityFlashcard;
        expect(flashcardAfterAnswer.lowPriorityStrength, greaterThan(flashcard.lowPriorityStrength));
        expect(flashcardAfterAnswer.lowPriorityStrength, foundFlashcard.lowPriorityStrength);
      });

      test('a low priority flashcard should not be marked as low priority again (updating the date time of enter in low priority)', () async {
        Flashcard flashcard = LowPriorityFlashcard(
            lowPriorityStrength: 2,
            base: Flashcard(
            term: 'term',
            definition: 'definition',
            lastSeenAt: DateTime.now(),
            strength: 2
          ),
          lowPriorityInfo: LowPriorityInfo(
            duration: Duration(hours: 4),
            enterDateTime: DateTime.now()
          )
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: true);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer, isA<LowPriorityFlashcard>());
        expect(foundFlashcard, isA<LowPriorityFlashcard>());
        expect(
          (flashcardAfterAnswer as LowPriorityFlashcard).lowPriorityInfo.enterDateTime.toIso8601String(),
          (flashcard as LowPriorityFlashcard).lowPriorityInfo.enterDateTime.toIso8601String()
        );
        expect(
          flashcardAfterAnswer.lowPriorityInfo.enterDateTime.toIso8601String(),
          (foundFlashcard as LowPriorityFlashcard).lowPriorityInfo.enterDateTime.toIso8601String()
        );
      });
    });

    group('when answering wrongly...', () {

      test('a low priority card should not have its duration or enter date time changed', () async {
        var flashcard = LowPriorityFlashcard(
            lowPriorityStrength: 2,
            base: Flashcard(
            term: 'term',
            definition: 'definition',
            lastSeenAt: DateTime.now(),
            strength: 2
          ),
          lowPriorityInfo: LowPriorityInfo(
            duration: Duration(hours: 4),
            enterDateTime: DateTime.now()
          )
        );
        flashcard = (await flashcardRepository.save(flashcard)) as LowPriorityFlashcard;
        final flashcardAfterAnswer = (await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: false)) as LowPriorityFlashcard;
        final foundFlashcard = (await flashcardRepository.findById(flashcardAfterAnswer.id!)) as LowPriorityFlashcard;
        expect(flashcardAfterAnswer, isA<LowPriorityFlashcard>());
        expect(foundFlashcard, isA<LowPriorityFlashcard>());
        expect(flashcardAfterAnswer.lowPriorityInfo.expiresAt, flashcard.lowPriorityInfo.expiresAt);
        expect(foundFlashcard.lowPriorityInfo.expiresAt, flashcard.lowPriorityInfo.expiresAt);
      });

      test('a low priority flashcard should have its strength and lowPriorityStrength decreased', () async {
        final flashcard = LowPriorityFlashcard(
            lowPriorityStrength: 2,
            base: Flashcard(
            term: 'term',
            definition: 'definition',
            lastSeenAt: DateTime.now(),
            strength: 2
          ),
          lowPriorityInfo: LowPriorityInfo(
            duration: Duration(hours: 4),
            enterDateTime: DateTime.now()
          )
        );
        await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: false) as LowPriorityFlashcard;
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer.strength, lessThan(flashcard.strength));
        expect(flashcardAfterAnswer.lowPriorityStrength, lessThan(flashcard.lowPriorityStrength));
        expect(foundFlashcard.strength, flashcardAfterAnswer.strength);
      });

      test('a non low priority flashcard should have its strength decreased', () async {
        Flashcard flashcard = Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 2
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: false);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer.strength, lessThan(flashcard.strength));
        expect(foundFlashcard.strength, flashcardAfterAnswer.strength);
      });

      test('a non low priority flashcard should be marked as low priority for 30 minutes and have its lowPriorityStrength set to be the same as strength', () async {
        Flashcard flashcard = Flashcard(
          term: 'term',
          definition: 'definition',
          lastSeenAt: DateTime.now(),
          strength: 3
        );
        flashcard = await flashcardRepository.save(flashcard);
        final flashcardAfterAnswer = await answerFlashcardUseCase.call(flashcard: flashcard.copyWith(), answeredCorrectly: false);
        final foundFlashcard = await flashcardRepository.findById(flashcardAfterAnswer.id!);
        expect(flashcardAfterAnswer, isA<LowPriorityFlashcard>());
        expect(foundFlashcard, isA<LowPriorityFlashcard>());
        expect((flashcardAfterAnswer as LowPriorityFlashcard).lowPriorityInfo.duration, Duration(minutes: 30));
        expect((foundFlashcard as LowPriorityFlashcard).lowPriorityInfo.duration, Duration(minutes: 30));
        expect((flashcardAfterAnswer).lowPriorityStrength, (flashcardAfterAnswer).strength);
        expect((foundFlashcard).lowPriorityStrength, (foundFlashcard).strength);
      });
    });
  });

}