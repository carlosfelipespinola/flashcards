import 'package:flashcards/domain/interfaces/tag.repository.dart';
import 'package:flashcards/domain/models/tag.dart';

class FindTagsUseCase {

  final ITagRepository tagRepository;
  FindTagsUseCase({
    required this.tagRepository,
  });

  Future<List<Tag>> call(Tag tag) async {
    return await tagRepository.findAll();
  }

}
