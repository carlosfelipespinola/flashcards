import 'package:flutter/material.dart';

import 'package:flashcards/domain/models/fashcard.dart';

class FlashcardDetailsBottomDialog extends StatelessWidget {
  final Flashcard flashcard;
  final void Function() onEdit;
  final void Function() onDelete;

  const FlashcardDetailsBottomDialog({
    Key? key,
    required this.flashcard,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            TextButton.icon(
              onPressed: onDelete, 
              icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
              label: Text('Delete', style: TextStyle(color: Theme.of(context).errorColor),),
            ),
            SizedBox(width: 12,),
            ElevatedButton.icon(
              onPressed: onEdit, 
              icon: Icon(Icons.edit), label: Text('Edit')
            )
          ],
        )
      ],
    );
  }
}