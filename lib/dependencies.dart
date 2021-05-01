import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/usecases/delete_category.usecase.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/domain/usecases/find_categories.usecase.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/domain/usecases/generate_lesson.usecase.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
import 'package:flashcards/domain/usecases/save_flashcard.usecase.dart';
import 'package:flashcards/services/database.dart';
import 'package:get_it/get_it.dart';

void setupDependencies() {
  _setupCategoryUseCasesAndRepositories();
  _setupFlashcardUseCasesAndRepositories();
  _setUpLessonUseCases();
  _setupServices();
}

void _setupCategoryUseCasesAndRepositories() {
  GetIt.I.registerLazySingleton<FindCategoriesUseCase>(() => FindCategoriesUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<SaveCategoryUseCase>(() => SaveCategoryUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<DeleteCategoryUseCase>(() => DeleteCategoryUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<ICategoryRepository>(() => CategoryRepository(databaseProvider: GetIt.I()));
}

void _setupFlashcardUseCasesAndRepositories() {
  GetIt.I.registerLazySingleton<FindFlashcardsUseCase>(() => FindFlashcardsUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<SaveFlashcardUseCase>(() => SaveFlashcardUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<DeleteFlashcardUseCase>(() => DeleteFlashcardUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<IFlashcardRepository>(() => FlashcardRepository(databaseProvider: GetIt.I()));
}

void _setUpLessonUseCases() {
  GetIt.I.registerLazySingleton<GenerateLessonUseCase>(() => GenerateLessonUseCase(flashcardRepository: GetIt.I()));
}

void _setupServices() {
  GetIt.I.registerSingleton<DatabaseProvider>(DatabaseProvider(test: false));
}