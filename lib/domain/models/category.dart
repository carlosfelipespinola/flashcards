
class Category {
  int? id;
  String name;
  final int? flashcardsCount;
  Category({
    this.id,
    required this.name,
    this.flashcardsCount
  });

  Category copyWith({
    int? id,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      flashcardsCount: this.flashcardsCount
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Category &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
