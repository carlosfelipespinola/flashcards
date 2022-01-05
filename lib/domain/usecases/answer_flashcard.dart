
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/flashcard_low_priority.dart';

class AnswerFlashcard {

  final IFlashcardRepository _flashcardRepository;
  AnswerFlashcard({
    required IFlashcardRepository flashcardRepository,
  }) : _flashcardRepository = flashcardRepository;

  Future<Flashcard> call({required Flashcard flashcard, required bool answeredCorrectly}) async {
    if (!flashcard.isValid()) {
      throw Failure();
    }
    if (answeredCorrectly) {
      flashcard = _answerCorrectly(flashcard);
    } else {
      flashcard = _answerWrongly(flashcard);
    }
    flashcard.markAsSeenNow();
    return await _flashcardRepository.save(flashcard);
  }

  Flashcard _answerCorrectly(Flashcard flashcard) {
    flashcard.increaseStrength();
    return _turnFlashcardIntoLowPriority(flashcard);
  }

  Flashcard _answerWrongly(Flashcard flashcard) {
    flashcard.decreaseStrength();
    return _turnFlashcardIntoNonLowPriority(flashcard);
  }

  LowPriorityFlashcard _turnFlashcardIntoLowPriority(Flashcard flashcard) {
    if (flashcard is LowPriorityFlashcard) {
      return flashcard;
    } else {
      return LowPriorityFlashcard.fromFlashcard(flashcard, Duration(hours: 12));
    }
  }

  Flashcard _turnFlashcardIntoNonLowPriority(Flashcard flashcard) {
    if (flashcard is LowPriorityFlashcard) {
      return flashcard.toNonLowPriority();
    }
    return flashcard;
  } 
}
