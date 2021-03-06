
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/answer_flashcard.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/themes.dart';
import 'package:flashcards/ui/pages/lesson/lesson.page.arguments.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flashcards/ui/widgets/progress_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class LessonPage extends StatefulWidget {
  final LessonPageArguments arguments;

  const LessonPage({Key? key, required this.arguments}) : super(key: key);
  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {

  final AnswerFlashcard answerFlashcard = GetIt.I();

  late final List<Flashcard> flashcards;

  GlobalKey<FlashcardTileState> flashCardTileKey = GlobalKey();

  int currentFlashcard = 0;

  int correctlyAnsweredCount = 0;

  bool hasSeenCurrentCard = false;

  SystemUiOverlayStyle? initialOverlayStyle;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    flashcards = widget.arguments.flashcards..shuffle();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initialOverlayStyle = Theme.of(context).appBarTheme.systemOverlayStyle;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (initialOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(initialOverlayStyle!);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProgressAppBar(progress: progress,),
      body: Builder(
        builder: (context) {
          if (flashcards.length == 0) {
            return Center(
              child: Text(MyAppLocalizations.of(context).noFlashcardsFoundMessage)
            );
          }
          if (hasFinished) return buildResultBody();
          else return buildCurrentFlashcard();
        }
      ),
      floatingActionButtonLocation:  FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: hasFinished ? null : buildAnswerOptions(),
      floatingActionButton: hasFinished ? buildEndLessonButton() : null,
    );
  }

  Widget buildCurrentFlashcard() {
    return Center(
      child: FlashcardTile(
        key: flashCardTileKey,
        onTurned: (showingFront) {
          setState(() {
            hasSeenCurrentCard = true;
          });
        },
        flashcard: flashcards.elementAt(currentFlashcard),
        size: double.infinity,
        maxSize: 350
      ),
    );
  }

  Widget buildResultBody() {
    return Theme(
      data: ThemeUtils.isDarkTheme(Theme.of(context)) ? generateDarkTheme(Colors.green) : generateLightTheme(Colors.green),
      child: Builder(
        builder: (context) {
          return Center(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 170,
                      minHeight: 170,
                      maxHeight: 170,
                      maxWidth: 170
                    ),
                    child: CircularProgressIndicator(
                      value: result / 100.0,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      backgroundColor: Theme.of(context).errorColor,
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$result%',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget buildAnswerOptions () {
    
    return Theme(
      data: ThemeUtils.isDarkTheme(Theme.of(context)) ? generateDarkTheme(Colors.green) : generateLightTheme(Colors.green),
      child: Builder(
        builder: (context) {
          return ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonMinWidth: 100,
            buttonHeight: 50,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100,
                  minHeight: 50
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Theme.of(context).errorColor),
                  onPressed: hasSeenCurrentCard ? answerWrongly : null,
                  child: Icon(Icons.close),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100,
                  minHeight: 50
                ),
                child: ElevatedButton(
                  onPressed: hasSeenCurrentCard ? answerCorrectly : null,
                  child: Icon(Icons.check),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget buildEndLessonButton() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pop(),
          label: Text(MyAppLocalizations.of(context).finish)
        ),
      ),
    );
  }

  double get progress {
    if (flashcards.length == 0) {
      return 1;
    }
    return currentFlashcard / flashcards.length;
  }

  int get result => ((correctlyAnsweredCount * 100) ~/ flashcards.length);

  bool get hasFinished => progress == 1;

  void answerCorrectly() {
    answerFlashcard.call(flashcard: flashcards.elementAt(currentFlashcard), answeredCorrectly: true);
    setState(() {
      correctlyAnsweredCount++;
    });
    nextCard();
  }

  void answerWrongly() {
    answerFlashcard.call(flashcard: flashcards.elementAt(currentFlashcard), answeredCorrectly: false);
    nextCard();
  }

  void nextCard() {
    flashCardTileKey.currentState?.restore();
    setState(() {
      hasSeenCurrentCard = false;
      currentFlashcard++;
    });
  }

}