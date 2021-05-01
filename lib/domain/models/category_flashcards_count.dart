
import 'package:flashcards/domain/models/category.dart';

class CategoryFlashcardsCount {
  final Category? category;
  final int flashcardsCount;

  CategoryFlashcardsCount({
    this.category,
    required this.flashcardsCount,
  });
}
