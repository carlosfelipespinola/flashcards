import 'package:auto_size_text/auto_size_text.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flutter/material.dart';

import 'package:flashcards/ui/widgets/turnable_card.dart';

class FlashcardTile extends StatefulWidget {

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
  FlashcardTileState createState() => FlashcardTileState();
}

class FlashcardTileState extends State<FlashcardTile> {

  final GlobalKey<TurnableCardState> _turnableCardKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return TurnableCard(
      key: _turnableCardKey,
      maxSize: widget.maxSize,
      size: widget.size,
      longPress: widget.onLongPress,
      onTurned: widget.onTurned,
      builder: (context, isShowingFront) {
        if ( isShowingFront ) {
          return Center(
              child: AutoSizeText(
                widget.flashcard.term,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              )
          );
        } else {
          return Center(
              child: AutoSizeText(
                widget.flashcard.definition,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              )
          );
        }
      },
    );
  }

  void restore() => _turnableCardKey.currentState?.restore();
}
