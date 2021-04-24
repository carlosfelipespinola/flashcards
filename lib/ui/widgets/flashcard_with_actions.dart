
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/ui/widgets/turnable_card.dart';
import 'package:flutter/material.dart';

class FlashCardTileWithActions extends StatefulWidget {

  final double size;
  final Flashcard flashCard;
  final void Function() onDelete;
  final void Function() onEdit;
  const FlashCardTileWithActions({
    Key? key,
    required this.flashCard, 
    required this.onDelete,
    required this.onEdit,
    this.size = 300
  }) : super(key: key);

  @override
  __FlashCardTileState createState() => __FlashCardTileState();
}

class __FlashCardTileState extends State<FlashCardTileWithActions> {

  final termController = TextEditingController();
  final definitionController = TextEditingController();

  @override
  void initState() {
    termController.text = widget.flashCard.term;
    definitionController.text = widget.flashCard.definition;
    super.initState();
  }

  @override
  void didUpdateWidget(FlashCardTileWithActions oldWidget) {
    termController.text = widget.flashCard.term;
    definitionController.text = widget.flashCard.definition;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    termController.dispose();
    definitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(icon: Icon(Icons.delete), onPressed: widget.onDelete),
                IconButton(icon: Icon(Icons.edit), onPressed: widget.onEdit),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.flashCard.category != null) ...[
                    Flexible(
                      fit: FlexFit.tight,
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: Text(widget.flashCard.category!.name, textAlign: TextAlign.center),
                        )
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.all(0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: Text(widget.flashCard.strength.toString(), textAlign: TextAlign.center),
                        )
                      ),
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return TurnableCard(
                      maxSize: constraints.maxWidth,
                      size: widget.size,
                      builder: (context, isShowingFront) {
                        if ( isShowingFront ) {
                          return Center(
                              child: AutoSizeText(
                                widget.flashCard.term,
                                style: TextStyle(fontSize: 18.0),
                                textAlign: TextAlign.center,
                              )
                          );
                        } else {
                          return Center(
                              child: AutoSizeText(
                                widget.flashCard.definition,
                                style: TextStyle(fontSize: 18.0),
                                textAlign: TextAlign.center,
                              )
                          );
                        }
                      },
                    );
                  }
                ),
              ),
            ],
          )
        ),
        Flexible(
          flex: 1, 
          child: Container()
        )
      ],
    );
  }
}