
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class DeleteFlashcardUseCase {

  final IFlashcardRepository flashcardRepository;
  DeleteFlashcardUseCase({
    required this.flashcardRepository,
  });

  Future<Flashcard> call(Flashcard flashcard) async {
    return await flashcardRepository.delete(flashcard);
  }

}
