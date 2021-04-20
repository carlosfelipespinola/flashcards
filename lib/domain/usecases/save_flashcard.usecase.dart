
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class SaveFlashcardUseCase {

  final IFlashcardRepository flashcardRepository;
  SaveFlashcardUseCase({
    required this.flashcardRepository,
  });

  Future<Flashcard> call(Flashcard flashcard) async {
    if (!flashcard.isValid()) {
      throw Failure();
    }
    return await flashcardRepository.save(flashcard);
  }

}
