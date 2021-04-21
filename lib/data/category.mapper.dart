
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/domain/models/category.dart';

class CategoryMapper {
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      name: map[CategorySchema.name],
      id: map[CategorySchema.id] as int
    );
  }

  static Map<String, dynamic> toMap(Category category) {
    return <String, dynamic>{
      CategorySchema.id: category.id,
      CategorySchema.name: category.name
    };
  }
}