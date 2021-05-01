
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class AnswerFlashcard {

  final IFlashcardRepository flashcardRepository;
  AnswerFlashcard({
    required this.flashcardRepository,
  });

  Future<Flashcard> call({required Flashcard flashcard, required bool answeredCorrectly}) async {
    if (!flashcard.isValid()) {
      throw Failure();
    }
    if (answeredCorrectly) {
      flashcard.increaseStrength();
    } else {
      flashcard.decreaseStrength();
    }
    print('answering ${flashcard.term} as $answeredCorrectly and current strength ${flashcard.strength}');
    flashcard.markAsSeenNow();
    return await flashcardRepository.save(flashcard);
  }

}
