import 'category.dart';

abstract class FlashcardFilter {}

class FlashcardCategoryFilter extends FlashcardFilter {
  Category? category;

  FlashcardCategoryFilter({
    required this.category,
  });
}

class OnlyLowPriorityFlashcardsFilter extends FlashcardFilter {}

class ExceptLowPriorityFlashcardsFilter extends FlashcardFilter {}

class FlashcardSearchFilter extends FlashcardFilter {
  String search;
  FlashcardSearchFilter({
    required this.search,
  });
}

