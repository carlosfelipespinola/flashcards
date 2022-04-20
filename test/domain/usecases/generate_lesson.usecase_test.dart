import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/data/flashcard.schema.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flashcards/domain/models/lesson_settings.dart';
import 'package:flashcards/domain/usecases/generate_lesson.usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

void main() async {
  var dbProvider = DatabaseProvider(test: true);
  var flashcardRepository = FlashcardRepository(databaseProvider: dbProvider);
  var generateLessonUseCase = GenerateLessonUseCase(flashcardRepository: flashcardRepository);
  
 
  group('Generate lesson tests...', () {
    setUp(() {
      return Future(() async {
        final flashcards = [
          ...List.generate(5, (index) => Flashcard(
            term: 'term $index',
            definition: 'definition $index',
            lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
            strength: 1,
            id: null
          )),
          ...List.generate(10, (index) => Flashcard(
            term: 'term $index',
            definition: 'definition $index',
            lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
            strength: 2,
            id: null,
          )),
          ...List.generate(5, (index) => Flashcard(
            term: 'term $index',
            definition: 'definition $index',
            lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
            strength: 3,
            id: null
          )),
          ...List.generate(5, (index) => LowPriorityFlashcard(
            lowPriorityStrength: 2,
            base: Flashcard(
              term: 'term $index',
              definition: 'definition $index',
              lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
              strength: 2,
              id: null,
            ),
            lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now().subtract(Duration(seconds: 1)), duration: Duration(hours: 4)
            )
          )),
          ...List.generate(2, (index) => LowPriorityFlashcard(
            lowPriorityStrength: 3,
            base: Flashcard(
              term: 'term $index',
              definition: 'definition $index',
              lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
              strength: 3,
              id: null,
            ),
            lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now().subtract(Duration(seconds: 1)), duration: Duration(hours: 4)
            )
          )),
          ...List.generate(2, (index) => LowPriorityFlashcard(
            lowPriorityStrength: 5,
            base: Flashcard(
              term: 'term $index',
              definition: 'definition $index',
              lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
              strength: 2,
              id: null,
            ),
            lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now().subtract(Duration(seconds: 1)), duration: Duration(hours: 4)
            )
          )),
          ...List.generate(1, (index) => LowPriorityFlashcard(
            lowPriorityStrength: 2,
            base: Flashcard(
              term: 'term $index',
              definition: 'definition $index',
              lastSeenAt: DateTime.now().subtract(Duration(minutes: index)),
              strength: 5,
              id: null,
            ),
            lowPriorityInfo: LowPriorityInfo(enterDateTime: DateTime.now().subtract(Duration(seconds: 1)), duration: Duration(hours: 4)
            )
          )),
        ];
        for (var flashcard in flashcards) { await flashcardRepository.save(flashcard); }
      });
    });

    tearDown(() {
      return Future(() async {
        var database = await dbProvider.db;
        await database.delete(FlashcardSchema.tableName);
      });
    });

    test('when there are enough high priority flashcards no low priority flashcards should be selected', () async {
      List<Flashcard> selectedFlashcards = await generateLessonUseCase.call(LessonSettings(flashcardsCount: 10));
      expect(selectedFlashcards.where((f) => f.strength == 1).length, 5);
      expect(selectedFlashcards.where((f) => f.strength == 2).length, 5);
      expect(selectedFlashcards.where((f) => f is LowPriorityFlashcard).length, 0);
    });

    test("when there aren't enough high priority flashcards low priority flashcards should be selected", () async {
      List<Flashcard> selectedFlashcards = await generateLessonUseCase.call(LessonSettings(flashcardsCount: 25));
      expect(selectedFlashcards.where((f) => f.strength == 1 && !(f is LowPriorityFlashcard)).length, 5, reason: 'because it should have 5 strength 1 flashcards');
      expect(selectedFlashcards.where((f) => f.strength == 2 && !(f is LowPriorityFlashcard)).length, 10, reason: 'because it should have 10 strength 2 flashcards');
      expect(selectedFlashcards.where((f) => f.strength == 3 && !(f is LowPriorityFlashcard)).length, 5, reason: 'because it should have 5 strength 3 flashcards');
      expect(selectedFlashcards.where((f) => f is LowPriorityFlashcard).length, 5, reason: 'because it should have 5 low priority flashcards');
    });

    test('when selecting all flashcards the following order should match: high priority ordered by (strenght asc, last seen asc), low priority (lowPriorityStrength asc, last seen asc)', () {
      return Future(() async {
        List<Flashcard> selectedFlashcards = await generateLessonUseCase.call(LessonSettings(flashcardsCount: 30));
        expect(selectedFlashcards.length, 30);
        List<Flashcard> selectedFlashcardsOrdered = selectedFlashcards.toList()..sort((a, b) {
          int comparison = 0;
          if (a is LowPriorityFlashcard && b is! LowPriorityFlashcard) {
            comparison = 1;
          } else if (a is! LowPriorityFlashcard && b is LowPriorityFlashcard) {
            comparison = -1;
          } else if (a is! LowPriorityFlashcard && b is! LowPriorityFlashcard) {
            comparison = a.strength.compareTo(b.strength);
          } else if (a is LowPriorityFlashcard && b is LowPriorityFlashcard) {
            comparison = a.lowPriorityStrength.compareTo(b.lowPriorityStrength);
          }
          if (comparison != 0) {
            return comparison;
          }
          comparison = a.lastSeenAt.compareTo(b.lastSeenAt);
          return comparison;
        });
        expect(ListEquality().equals(selectedFlashcards, selectedFlashcardsOrdered), true);
      });
      
    });

  });

}