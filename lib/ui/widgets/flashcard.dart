import 'package:auto_size_text/auto_size_text.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flutter/material.dart';

import 'package:flashcards/ui/widgets/turnable_card.dart';

class FlashcardTile extends StatelessWidget {

  final double maxSize;
  final double size;
  final Flashcard flashcard;

  const FlashcardTile({
    Key? key,
    required this.maxSize,
    required this.size,
    required this.flashcard
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TurnableCard(
      maxSize: maxSize,
      size: size,
      longPress: () {
        showBottomSheetWithDetails(context);
      },
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

  void showBottomSheetWithDetails(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Text('Strength'),
                  trailing: Text(flashcard.strength.toString()),
                ),
                ListTile(
                  leading: Text('Category'),
                  trailing: Text(flashcard.category?.name ?? '-'),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {}, 
                  icon: Icon(Icons.delete), label: Text('Delete')
                ),
                SizedBox(width: 12,),
                ElevatedButton.icon(
                  onPressed: () {}, 
                  icon: Icon(Icons.edit), label: Text('Edit')
                )
              ],
            )
          ],
        );
      }
    );
  }
}
