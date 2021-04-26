import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flashcards/ui/widgets/try_again.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';

class FlashcardsPage extends StatefulWidget {
  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late FindFlashcardsUseCase findFlashcardsUseCase;
  List<Flashcard> flashcards = [];
  bool fetchFlashcardsFailed = false;
  bool isFetchingFlashcards = false;

  @override
  void initState() {
    findFlashcardsUseCase = GetIt.I.get<FindFlashcardsUseCase>();
    fetchFlashcards();
    super.initState();
  }

  void fetchFlashcards() async {
    try {
      this.isFetchingFlashcards = true;
      final foundFlashcards = await findFlashcardsUseCase();
      setState(() {
        this.flashcards = foundFlashcards;
        this.fetchFlashcardsFailed = false;
        this.isFetchingFlashcards = false;
      });
    } catch (error) {
      this.isFetchingFlashcards = false;
      this.fetchFlashcardsFailed = true;
    }
    
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('My Flashcards'.toUpperCase(), style: Theme.of(context).appBarTheme.textTheme!.headline6, overflow: TextOverflow.ellipsis, maxLines: 1,),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isFetchingFlashcards) {
              return Center(child: CircularProgressIndicator());
            }
            if (fetchFlashcardsFailed) {
              return Center(
                child: TryAgain(
                  message: 'Algo deu errado, tente novamente.',
                  onPressed: fetchFlashcards
                ),
              );
            }
            if (flashcards.length == 0) {
              return Center(
                child: Text('Você ainda não tem nenhum flashcard cadastrado'),
              );
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = flashcards.elementAt(index);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return FlashcardTile(
                      maxSize: constraints.maxWidth, 
                      size: constraints.maxWidth,
                      flashcard: flashcard
                    );
                  }
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
            onTap: () async {
              await Navigator.of(context).pushNamed(RoutesPaths.flashcardEditor);
              fetchFlashcards();
            },
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