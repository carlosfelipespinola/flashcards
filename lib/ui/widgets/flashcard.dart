import 'package:auto_size_text/auto_size_text.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flutter/material.dart';

import 'package:flashcards/ui/widgets/turnable_card.dart';

class FlashcardTile extends StatelessWidget {

  final double maxSize;
  final double size;
  final Flashcard flashcard;
  final void Function()? onLongPress;
  final void Function(bool)? onTurned;

  const FlashcardTile({
    Key? key,
    required this.maxSize,
    required this.size,
    required this.flashcard,
    this.onTurned,
    this.onLongPress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TurnableCard(
      maxSize: maxSize,
      size: size,
      longPress: onLongPress,
      onTurned: onTurned,
      builder: (context, isShowingFront) {
        if ( isShowingFront ) {
          return Center(
              child: AutoSizeText(
                flashcard.term,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              )
          );
        } else {
          return Center(
              child: AutoSizeText(
                flashcard.definition,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              )
          );
        }
      },
    );
  }
}
