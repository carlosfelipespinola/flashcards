import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FlashcardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('My Flashcards'.toUpperCase(), style: Theme.of(context).appBarTheme.textTheme!.headline6, overflow: TextOverflow.ellipsis, maxLines: 1,),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
          itemCount: 10,
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return FlashcardTile(
                  maxSize: constraints.maxWidth, 
                  size: constraints.maxWidth,
                  flashcard: Flashcard(
                    id: null,
                    term: 'Qual é a menor nota que podemos encontrar na musica?',
                    definition: 'Teste 2',
                    lastSeenAt: DateTime.now(),
                    strength: 2,
                    category: null
                  )
                );
              }
            );
          }
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: true,
        curve: Curves.bounceIn,
        backgroundColor: Theme.of(context).primaryColor,
        children: [
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.add),
            onTap: () async {},
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                'Create Flashcard'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.play_arrow),
            onTap: () async {},
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                'Start Lesson'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.filter_alt),
            onTap: () async {},
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                'Filter Flashcards'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.label),
            onTap: () async {},
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                'Manage Categories'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
          SpeedDialChild(
            elevation: 2,
            child: Icon(Icons.info_outline),
            onTap: () async {
              showLicensePage(context: context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Container(
              margin: EdgeInsets.only(right: 12),
              child: Text(
                'About the app'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorBrightness == Brightness.dark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}