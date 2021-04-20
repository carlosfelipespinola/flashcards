
import 'package:flashcards/data/category.schema.dart';
import 'package:flashcards/domain/models/category.dart';

class CategoryMapper {
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      name: map[CategorySchema.name],
      id: map[CategorySchema.id]
    );
  }

  static Map<String, dynamic> toJson(Category category) {
    return <String, dynamic>{
      CategorySchema.id: category.id,
      CategorySchema.name: category.name
    };
  }
}