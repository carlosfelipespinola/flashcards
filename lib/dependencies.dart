import 'package:flashcards/data/app_settings.repository.dart';
import 'package:flashcards/data/category.repository.dart';
import 'package:flashcards/data/flashcard.repository.dart';
import 'package:flashcards/domain/interfaces/app_settings.repository.dart';
import 'package:flashcards/domain/interfaces/category.repository.dart';
import 'package:flashcards/domain/interfaces/flashcard.repository.dart';
import 'package:flashcards/domain/usecases/answer_flashcard.dart';
import 'package:flashcards/domain/usecases/delete_category.usecase.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/domain/usecases/find_categories.usecase.dart';
import 'package:flashcards/domain/usecases/find_categories_couting_flashcards.usecase.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/domain/usecases/generate_lesson.usecase.dart';
import 'package:flashcards/domain/usecases/load_settings.usecase.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
import 'package:flashcards/domain/usecases/save_flashcard.usecase.dart';
import 'package:flashcards/data/database.dart';
import 'package:flashcards/domain/usecases/save_settings.usecase.dart';
import 'package:flashcards/services/app_info/app_info.dart';
import 'package:flashcards/services/app_info/app_info_impl.dart';
import 'package:get_it/get_it.dart';

Future<void> setupDependencies() async {
  _setupCategoryUseCasesAndRepositories();
  _setupFlashcardUseCasesAndRepositories();
  _setUpLessonUseCases();
  _setUpAppSettingsUseCasesAndRepositories();
  await _setupServices();
}

void _setupCategoryUseCasesAndRepositories() {
  GetIt.I.registerLazySingleton(() => FindCategoriesCountingFlashcardsUseCase(
    categoryRepository: GetIt.I(),
    flashcardRepository: GetIt.I())
  );
  GetIt.I.registerLazySingleton(() => FindCategoriesUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => SaveCategoryUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => DeleteCategoryUseCase(categoryRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<ICategoryRepository>(() => CategoryRepository(databaseProvider: GetIt.I()));
}

void _setupFlashcardUseCasesAndRepositories() {
  GetIt.I.registerLazySingleton(() => AnswerFlashcard(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => FindFlashcardsUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => SaveFlashcardUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => DeleteFlashcardUseCase(flashcardRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<IFlashcardRepository>(() => FlashcardRepository(databaseProvider: GetIt.I()));
}

void _setUpLessonUseCases() {
  GetIt.I.registerLazySingleton(() => GenerateLessonUseCase(flashcardRepository: GetIt.I()));
}

Future<void> _setUpAppSettingsUseCasesAndRepositories() async {
  GetIt.I.registerLazySingleton(() => SaveSettingsUseCase(appSettingsRepository: GetIt.I()));
  GetIt.I.registerLazySingleton(() => LoadSettingsUseCase(appSettingsRepository: GetIt.I()));
  GetIt.I.registerLazySingleton<IAppSettingsRepository>(() => AppSettingsRepository(databaseProvider: GetIt.I()));
}

Future<void> _setupServices() async {
  final appInfo = AppInfoImpl();
  await appInfo.loadInfos();
  GetIt.I.registerLazySingleton<AppInfo>(() => appInfo);
  GetIt.I.registerSingleton(DatabaseProvider(test: false));
}