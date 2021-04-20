
import 'package:flashcards/domain/interfaces/tag.repository.dart';
import 'package:flashcards/domain/models/tag.dart';

class TagRepository implements ITagRepository {
  @override
  Future<Tag> delete(Tag tag) {
    throw UnimplementedError();
  }

  @override
  Future<List<Tag>> findAll() {
    throw UnimplementedError();
  }

  @override
  Future<Tag> save(Tag tag) {
    throw UnimplementedError();
  }

}