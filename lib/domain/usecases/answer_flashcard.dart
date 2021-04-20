
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class SaveFlashcardUseCase {

  final IFlashcardRepository flashcardRepository;
  SaveFlashcardUseCase({
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
    flashcard.markAsSeenNow();
    return await flashcardRepository.save(flashcard);
  }

}
