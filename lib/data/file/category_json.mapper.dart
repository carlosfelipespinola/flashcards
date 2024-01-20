import 'dart:convert';

import '../../domain/models/category.dart';

class _CategoryJsonKeys {
  static String id = 'id';
  static String name = 'name';
}

class CategoryJsonMapper {
  static Category fromJson(String jsonSource) {
    final map = jsonDecode(jsonSource);
    return Category(
        name: map[_CategoryJsonKeys.name],
        id: map[_CategoryJsonKeys.id] as int);
  }

  static String toJson(Category category) {
    final map = <String, dynamic>{
      _CategoryJsonKeys.id: category.id,
      _CategoryJsonKeys.name: category.name
    };

    return jsonEncode(map);
  }
}
