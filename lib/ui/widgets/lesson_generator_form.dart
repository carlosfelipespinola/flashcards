import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/lesson_settings.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/domain/usecases/generate_lesson.usecase.dart';
import 'package:flashcards/ui/widgets/try_again.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class LessonGeneratorForm extends StatefulWidget {



  @override
  _LessonGeneratorFormState createState() => _LessonGeneratorFormState();
}

enum _LessonGeneratorSteps { selectCategory, selectQuantity, generatingLesson, generateLessonFailed }

class _LessonGeneratorFormState extends State<LessonGeneratorForm> {

  final FindFlashcardsUseCase findFlashcardsUseCase = GetIt.I();
  final GenerateLessonUseCase generateLessonUseCase = GetIt.I();
  late Future<List<Flashcard>> flashcards;
  _LessonGeneratorSteps step = _LessonGeneratorSteps.selectCategory;
  Category? chosenCategory;
  int count = 0;
  int maxCount = 10;

  @override
  void initState() {
    flashcards = findFlashcardsUseCase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: FutureBuilder<List<Flashcard>>(
        future: flashcards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return pending;
          if (snapshot.hasError) return tryAgainFetchFlashcards;
          if (snapshot.requireData.isEmpty) return noFlashcardsWarningText;
          if (step == _LessonGeneratorSteps.selectCategory) return buildSelectCategoryStep(snapshot.requireData);
          if (step == _LessonGeneratorSteps.selectQuantity) return selectQuantityStep;
          if (step == _LessonGeneratorSteps.generatingLesson) return pending;
          return tryAgainGenerateLesson;
        }
      )
    );
  }

  Widget get pending {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget get tryAgainFetchFlashcards {
    return Center(
      child: TryAgain(
        message: 'Ocorreu um erro, tente novamente.',
        onPressed: () {
          setState(() {
            flashcards = findFlashcardsUseCase();
          });
        }
      ),
    );
  }

  Widget get noFlashcardsWarningText {
    return Center(
      child: Text(
        'Não é possível praticar porque você ainda não tem flashcards cadastrado.',
        textAlign: TextAlign.center,
      )
    );
  }

  Widget buildSelectCategoryStep(List<Flashcard> flashcards) {
    final categories = extractCategoriesFromFlashcards(flashcards);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.elementAt(index);
              return ListTile(
                title: Text(category?.name ?? 'Sem categoria', style: Theme.of(context).textTheme.subtitle2),
                trailing: chosenCategory == category ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    chosenCategory = category;
                  });
                },
              );
            }
          )
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              step = _LessonGeneratorSteps.selectQuantity;
            });
          },
          child: Text('Próximo Passo'.toUpperCase())
        )
      ],
    );
  }

  List<Category?> extractCategoriesFromFlashcards(List<Flashcard> flashcards) {
    return flashcards.map((e) => e.category).toSet().toList();
  }

  Widget get selectQuantityStep {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantidade de flashcards',
            counterText: 'Digite um número de 1 até 10'
          ),
          onChanged: (value) {
            setState(() {
              try {
                count = int.parse(value);
              } catch (_) {
                count = 0;  
              }
            });
          },
        ),
        Spacer(),
        ElevatedButton(
          onPressed: count > 0 && count <= 10 ? () {
            generateLesson(LessonSettings(
              category: chosenCategory,
              flashcardsCount: count
            ));
          } : null,
          child: Text('Começar'.toUpperCase())
        )
      ],
    );
  }

  Widget get tryAgainGenerateLesson {
    return TryAgain(
      message: 'Ocorreu um erro ao filtrar flashcards para prática, tente novamente.',
      onPressed: () {
        generateLesson(LessonSettings(
          category: chosenCategory,
          flashcardsCount: count
        ));
      }
    );
  }

  void generateLesson(LessonSettings settings) async {
    try {
      setState(() {
        step = _LessonGeneratorSteps.generatingLesson;
      });
      final flashcardsForLesson = await generateLessonUseCase(settings);
      print(flashcardsForLesson);
    } catch (_) {
      setState(() {
        step = _LessonGeneratorSteps.generateLessonFailed;
      });
    }
  }
}