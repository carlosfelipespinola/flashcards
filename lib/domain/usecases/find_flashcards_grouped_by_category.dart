
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/sort.dart';
import "package:collection/collection.dart";

class FindFlashcardsGroupedByCategory {

  final IFlashcardRepository flashcardRepository;

  FindFlashcardsGroupedByCategory({
    required this.flashcardRepository,
  });

  Future<Map<Category?, List<Flashcard>>> call() async {
    final flashcards = await flashcardRepository.findAll(
      sortBy: [
        Sort(field: FlashcardSortableFields.strength, type: SortType.asc),
        Sort(field: FlashcardSortableFields.lastSeentAt, type: SortType.asc)
      ],
    );
    final map = groupBy<Flashcard, Category?>(flashcards, (flashcard) {
      return flashcard.category;
    });
    final sortedMapEntries = map.entries.sorted((a, b) {
      if (a.key == null) return 1;
      if (b.key == null) return -1;
      return a.key!.name.toLowerCase().compareTo(b.key!.name.toLowerCase());
    });
    return Map.fromEntries(sortedMapEntries);
  }

}
