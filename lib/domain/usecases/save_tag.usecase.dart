import 'package:flashcards/domain/interfaces/tag.repository.dart';
import 'package:flashcards/domain/models/tag.dart';

class SaveTagUseCase {

  final ITagRepository tagRepository;
  SaveTagUseCase({
    required this.tagRepository,
  });

  Future<Tag> call(Tag tag) async {
    return await tagRepository.save(tag);
  }

}
