
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flashcards/ui/widgets/try_again.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FlashcardGrid extends StatefulWidget {
  final void Function(Flashcard)? onFlashcardLongPress;

  const FlashcardGrid({Key? key, this.onFlashcardLongPress}) : super(key: key);
  @override
  FlashcardGridState createState() => FlashcardGridState();
}

class FlashcardGridState extends State<FlashcardGrid> {
  late FindFlashcardsUseCase findFlashcardsUseCase;
  late Future<List<Flashcard>> flashcards;

  @override
  void initState() {
    findFlashcardsUseCase = GetIt.I();
    fetchFlashcards();
    super.initState();
  }

  void fetchFlashcards() async {
    setState(() {
      flashcards = findFlashcardsUseCase();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Flashcard>>(
      future: flashcards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TryAgain(
              message: 'Algo deu errado, tente novamente.',
              onPressed: fetchFlashcards
            ),
          );
        }
        if (snapshot.requireData.isEmpty) {
          return Center(
            child: Text('Você ainda não tem nenhum flashcard cadastrado'),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => fetchFlashcards(),
          child: GridView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
            itemCount: snapshot.requireData.length,
            itemBuilder: (context, index) {
              final flashcard = snapshot.requireData.elementAt(index);
              return LayoutBuilder(
                builder: (context, constraints) {
                  return FlashcardTile(
                    maxSize: constraints.maxWidth, 
                    size: constraints.maxWidth,
                    flashcard: flashcard,
                    onLongPress: () {
                      if (widget.onFlashcardLongPress != null) {
                        widget.onFlashcardLongPress!(flashcard);
                      }
                    },
                  );
                }
              );
            }
          ),
        );
      }
    );
  }
}
