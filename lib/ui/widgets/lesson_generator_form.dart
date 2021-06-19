import 'package:flashcards/domain/models/category_flashcards_count.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/models/lesson_settings.dart';
import 'package:flashcards/domain/usecases/find_categories_couting_flashcards.usecase.dart';
import 'package:flashcards/domain/usecases/generate_lesson.usecase.dart';
import 'package:flashcards/ui/widgets/try_again.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class LessonGeneratorForm extends StatefulWidget {
  final void Function(List<Flashcard>) onGenerate;

  const LessonGeneratorForm({Key? key, required this.onGenerate}) : super(key: key);


  @override
  _LessonGeneratorFormState createState() => _LessonGeneratorFormState();
}

enum _LessonGeneratorSteps { selectCategory, selectQuantity, generatingLesson, generateLessonFailed }

class _LessonGeneratorFormState extends State<LessonGeneratorForm> {

  final FindCategoriesCountingFlashcardsUseCase findCategoriesCountingFlashcards = GetIt.I();
  final GenerateLessonUseCase generateLessonUseCase = GetIt.I();
  late Future<List<CategoryFlashcardsCount>> categoriesFlashcards;
  _LessonGeneratorSteps step = _LessonGeneratorSteps.selectCategory;
  CategoryFlashcardsCount? chosenCategory;
  int count = 0;
  int maxCount = 10;

  @override
  void initState() {
    categoriesFlashcards = findCategoriesCountingFlashcards();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: FutureBuilder<List<CategoryFlashcardsCount>>(
        future: categoriesFlashcards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return pending;
          if (snapshot.hasError) return tryAgainFetchFlashcards;
          if (snapshot.requireData.isEmpty) return noFlashcardsWarningText;
          if (snapshot.requireData.map((e) => e.flashcardsCount).reduce((a, b) => a + b) == 0)
            return noFlashcardsWarningText;
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
            categoriesFlashcards = findCategoriesCountingFlashcards();
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

  Widget buildSelectCategoryStep(List<CategoryFlashcardsCount> categoriesCoutingFlashcards) {
    categoriesCoutingFlashcards.retainWhere((element) => element.flashcardsCount > 0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Selecione uma categoria',
            style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: ListView.builder(
            itemCount: categoriesCoutingFlashcards.length,
            itemBuilder: (context, index) {
              final item = categoriesCoutingFlashcards.elementAt(index);
              return ListTile(
                title: Text(item.category?.name ?? 'Sem categoria', style: Theme.of(context).textTheme.subtitle2),
                trailing: chosenCategory != null && chosenCategory!.category == item.category ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    chosenCategory = item;
                  });
                },
              );
            }
          )
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: chosenCategory != null ? () {
            setState(() {
              step = _LessonGeneratorSteps.selectQuantity;
            });
          } : null,
          child: Text('Próximo Passo'.toUpperCase())
        )
      ],
    );
  }

  Widget get selectQuantityStep {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantidade de flashcards',
            counterText: 'Digite um número de 1 até ${chosenCategory!.flashcardsCount}'
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
          onPressed: count > 0 && count <= chosenCategory!.flashcardsCount ? () {
            generateLesson(LessonSettings(
              category: chosenCategory!.category,
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
          category: chosenCategory!.category,
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
      widget.onGenerate(flashcardsForLesson);
    } catch (_) {
      setState(() {
        step = _LessonGeneratorSteps.generateLessonFailed;
      });
    }
  }
}