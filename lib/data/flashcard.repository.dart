
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/sort.dart';

class FlashcardRepository implements IFlashcardRepository {
  @override
  Future<Flashcard> delete(Flashcard flashcard) {
      throw UnimplementedError();
    }
  
    @override
    Future<List<Flashcard>> findAll() {
      throw UnimplementedError();
    }
  
    @override
    Future<List<Flashcard>> query({Category? category, List<Sort<FlashcardSortableFields>>? sortBy, int? limit, bool? randomize = false}) {
      throw UnimplementedError();
    }
  
    @override
    Future<Flashcard> save(Flashcard flashcard) {
    throw UnimplementedError();
  }

}