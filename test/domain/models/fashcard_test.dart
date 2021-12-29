import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('a non low priority flashcard...', () {
    test('can have its strength increased', () {
      var flashcard = Flashcard(
        term: 'term 2',
        definition: 'definition 2',
        lastSeenAt: DateTime.now(),
        strength: 2,
        id: 2
      );
      expect(flashcard.runtimeType == LowPriorityFlashcard, false);
      int oldStrength = flashcard.strength;
      flashcard.increaseStrength();
      expect(oldStrength, lessThan(flashcard.strength));
    });

    test('can have its strength decreased', () {
      var flashcard = Flashcard(
        term: 'term 2',
        definition: 'definition 2',
        lastSeenAt: DateTime.now(),
        strength: 2,
        id: 2
      );
      expect(flashcard.runtimeType == LowPriorityFlashcard, false);
      int oldStrength = flashcard.strength;
      flashcard.decreaseStrength();
      expect(oldStrength, greaterThan(flashcard.strength));
    });
  });

  group('a low priority fashcard...', () {
    test('can be created from a non low priority flashcard', () {
      final flashcard = Flashcard(
        term: 'term 2',
        definition: 'definition 2',
        lastSeenAt: DateTime.now(),
        strength: 2,
        id: 2
      );
      final lowPriorityFlashcard = LowPriorityFlashcard.fromFlashcard(flashcard, Duration(hours: 4));
      expect(flashcard.category, lowPriorityFlashcard.category);
      expect(flashcard.definition, lowPriorityFlashcard.definition);
      expect(flashcard.term, lowPriorityFlashcard.term);
      expect(flashcard.strength, lowPriorityFlashcard.strength);
      expect(flashcard.id, lowPriorityFlashcard.id);
      expect(flashcard.lastSeenAt.toIso8601String(), lowPriorityFlashcard.lastSeenAt.toIso8601String());
    });

    test('cannot have its strength increased', () {
      final initialStrength = 2;
      var flashcard = LowPriorityFlashcard.fromFlashcard(
        Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: initialStrength,
          id: 2
        ),
        Duration(hours: 4)
      );
      expect(flashcard.isStillLowPriority, true);
      flashcard.increaseStrength();
      expect(flashcard.strength, initialStrength);
    });

    test('can have its strength decreased', () {
      final initialStrength = 2;
      final flashcard = LowPriorityFlashcard.fromFlashcard(
        Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: initialStrength,
          id: 2
        ),
        Duration(hours: 4)
      );
      expect(flashcard.isStillLowPriority, true);
      flashcard.decreaseStrength();
      expect(flashcard.strength < initialStrength, true);
    });

    test('can turn itself into a non low priority flashcard', () {
      final lowPriorityFlashcard = LowPriorityFlashcard.fromFlashcard(
        Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: 2,
          id: 2
        ),
        Duration(hours: 4)
      );
      var flashcard = lowPriorityFlashcard.toNonLowPriority();
      expect(identical(flashcard, lowPriorityFlashcard), false);
      expect(flashcard, isA<Flashcard>());
      expect(flashcard, isNot(isA<LowPriorityFlashcard>()));
      expect(flashcard.category, lowPriorityFlashcard.category);
      expect(flashcard.definition, lowPriorityFlashcard.definition);
      expect(flashcard.term, lowPriorityFlashcard.term);
      expect(flashcard.strength, lowPriorityFlashcard.strength);
      expect(flashcard.id, lowPriorityFlashcard.id);
      expect(flashcard.lastSeenAt.toIso8601String(), lowPriorityFlashcard.lastSeenAt.toIso8601String());
    });

  });

  group('when a fashcard entered in low priority...', () {

    test('3 hours and 59 seconds ago and its duration is 4 hours, it should be still in low priority', () {
      var flashcard = LowPriorityFlashcard(
        base: Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: 2,
          id: 2
        ),
        lowPriorityInfo: LowPriorityInfo(
          enterDateTime: DateTime.now().subtract(Duration(hours: 3, seconds: 59)),
          duration: Duration(hours: 4)
        ),
      );
      expect(flashcard.isStillLowPriority, true);
    });

    test('4 hours and 1 seconds ago and its duration is 4 hours, it should not be in low priority', () {
      var flashcard = LowPriorityFlashcard(
        base: Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: 2,
          id: 2
        ),
        lowPriorityInfo: LowPriorityInfo(
          enterDateTime: DateTime.now().subtract(Duration(hours: 4, seconds: 1)),
          duration: Duration(hours: 4)
        ),
      );
      expect(flashcard.isStillLowPriority, false);
    });

    test('any time in the future should not be considered in low priority (users can use the app while the clock is wrongly setted up)', () {
      var flashcard = LowPriorityFlashcard(
        base: Flashcard(
          term: 'term 2',
          definition: 'definition 2',
          lastSeenAt: DateTime.now(),
          strength: 2,
          id: 2
        ),
        lowPriorityInfo: LowPriorityInfo(
          enterDateTime: DateTime.now().add(Duration(seconds: 10)),
          duration: Duration(hours: 4)
        ),
      );
      expect(flashcard.isStillLowPriority, false);
    });

  });
  
}