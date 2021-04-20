import 'package:flashcards/domain/interfaces/tag.repository.dart';
import 'package:flashcards/domain/models/tag.dart';

class DeleteTagUseCase {

  final ITagRepository tagRepository;
  DeleteTagUseCase({
    required this.tagRepository,
  });

  Future<Tag> call(Tag tag) async {
    return await tagRepository.delete(tag);
  }

}
