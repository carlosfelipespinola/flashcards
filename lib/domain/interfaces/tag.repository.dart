
import 'package:flashcards/domain/models/tag.dart';

abstract class ITagRepository {
  Future<List<Tag>> findAll();
  Future<Tag> save(Tag tag);
  Future<Tag> delete(Tag tag);
}