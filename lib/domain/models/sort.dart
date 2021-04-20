
class Sort<T> {
  T field;
  SortType type;
  
  Sort({
    required this.field,
    required this.type
  });
}

enum SortType { asc, desc }