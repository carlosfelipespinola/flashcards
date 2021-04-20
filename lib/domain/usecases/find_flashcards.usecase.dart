
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';

class FindFlashcardsUseCase {

  final IFlashcardRepository flashcardRepository;
  FindFlashcardsUseCase({
    required this.flashcardRepository,
  });

  Future<List<Flashcard>> call() async {
    return await flashcardRepository.findAll();
  }

}
