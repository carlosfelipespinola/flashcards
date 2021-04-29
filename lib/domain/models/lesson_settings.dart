
import 'package:flashcards/domain/models/category.dart';

class LessonSettings {
  Category? category;
  int flashcardsCount;

  LessonSettings({
    this.category,
    required this.flashcardsCount,
  });
}
