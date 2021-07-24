
import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/domain/usecases/find_flashcards_grouped_by_category.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.arguments.dart';
import 'package:flashcards/ui/widgets/confirm_bottom_dialog.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flashcards/ui/widgets/try_again.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'flashcard_details_bottom_dialog.dart';

class FlashcardsGrid extends StatefulWidget {
  final void Function()? onScrollBottomEnter;
  final void Function()? onScrollBottomExit;

  const FlashcardsGrid({Key? key, this.onScrollBottomEnter, this.onScrollBottomExit}) : super(key: key);

  @override
  FlashcardsGridState createState() => FlashcardsGridState();
}

class FlashcardsGridState extends State<FlashcardsGrid> {

  late FindFlashcardsGroupedByCategory _findFlashcardsGroupedByCategory;

  late Future<Map<Category?, List<Flashcard>>> _mapCategoryFlashcardsFuture;

  Map<Category?, List<Flashcard>> _mapCategoryFlashcards = {};

  Set<Flashcard> _flashcardsBeingDeleted = {};

  final DeleteFlashcardUseCase _deleteFlashcardUseCase = GetIt.I();

  late ScrollController _scrollController;

  late bool _hasExitedScrollBottom;

  bool get _isScrollAtBottom =>_scrollController.hasClients && _scrollController.position.atEdge && _scrollController.position.pixels != 0;

  Flashcard? _hightLightedFlashcard;

  @override
  void initState() {
    _scrollController = ScrollController(debugLabel: 'flashcards-grid-scroll');
    _scrollController.addListener(_onScroll);
    _hasExitedScrollBottom = !_isScrollAtBottom;
    _findFlashcardsGroupedByCategory = GetIt.I();
    fetchFlashcards();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrollAtBottom) {
      widget.onScrollBottomEnter?.call();
      _hasExitedScrollBottom = false; 
    } else if (!_hasExitedScrollBottom) {
      _hasExitedScrollBottom = true;
      widget.onScrollBottomExit?.call();
    }
  }

  void fetchFlashcards() {
    setState(() {
      _mapCategoryFlashcardsFuture = _findFlashcardsGroupedByCategory();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Category?, List<Flashcard>>>(
      future: _mapCategoryFlashcardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _mapCategoryFlashcards.length == 0) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TryAgain(
              message: 'Algo deu errado, tente novamente.',
              onPressed: fetchFlashcards
            ),
          );
        }
        if (snapshot.requireData.isEmpty) {
          return Center(
            child: Text('Você ainda não tem nenhum flashcard cadastrado'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          _mapCategoryFlashcards = snapshot.requireData;
        }
        return RefreshIndicator(
          onRefresh: () async => fetchFlashcards(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _mapCategoryFlashcards.keys.length,
            itemBuilder: (context, categoryIndex) {
              final category = _mapCategoryFlashcards.keys.elementAt(categoryIndex);
              return StickyHeaderBuilder(
                builder: (context, factor) {
                  return Container(
                    height: kToolbarHeight + 1,
                    child: Opacity(
                      opacity: 0.80,
                      child: AppBar(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: factor == 1 ? 0.0 : 0.5,
                        title: Text(category?.name ?? 'Sem categoria', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                      ),
                    ),
                  );
                },
                content: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
                  itemCount: _mapCategoryFlashcards.values.elementAt(categoryIndex).length,
                  itemBuilder: (context, flashcardIndex) {
                    final flashcard = _mapCategoryFlashcards.values.elementAt(categoryIndex).elementAt(flashcardIndex);
                    final cardShape = Theme.of(context).cardTheme.shape;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: _hightLightedFlashcard == flashcard ? BoxDecoration(
                            border: Border.all(color: Theme.of(context).accentColor),
                            borderRadius: cardShape is RoundedRectangleBorder ? cardShape.borderRadius : null
                          ) : null,
                          child: FlashcardTile(
                            maxSize: constraints.maxWidth, 
                            size: constraints.maxWidth,
                            flashcard: flashcard,
                            onLongPress: () {
                              showFlashcardBottomDialog(flashcard);
                            },
                          ),
                        );
                      }
                    );
                  }
                )
              );
            },
          ),
        );
      }
    );
  }

  void showFlashcardBottomDialog(Flashcard flashcard) async {
    setState(() { _hightLightedFlashcard = flashcard; });
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return FlashcardDetailsBottomDialog(
          flashcard: flashcard,
          onEdit: () => Navigator.of(context).pop('edit'),
          onDelete: () => Navigator.of(context).pop('delete')
        );
      }
    );
    if (result == 'edit') {
      setState(() { _hightLightedFlashcard = null; });
      await Navigator.of(context).pushNamed(
        RoutesPaths.flashcardEditor,
        arguments: FlashcardEditorPageArguments(flashcard: flashcard)
      );
      fetchFlashcards();
    } else if (result == 'delete') {
      showFlashcardDeletionConfirmDialog(flashcard);
    } else {
      setState(() { _hightLightedFlashcard = null; });
    }
  }

  void showFlashcardDeletionConfirmDialog(Flashcard flashcard) async {
    if (_flashcardsBeingDeleted.contains(flashcard)) return;
    final shouldDelete = await showModalBottomSheet<bool?>(
      isScrollControlled: false,
      context: context,
      builder: (context) {
        return ConfirmBottomDialog(
          title: 'Deletar Flashcard',
          text: 'Você tem certeza que deseja deletar esse flashcard?',
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false)
        );
      }
    ) ?? false;
    if (shouldDelete) {
      await deleteFlashcard(flashcard);
      fetchFlashcards();
    }
    setState(() { _hightLightedFlashcard = null; });
  }

  Future<void> deleteFlashcard(Flashcard flashcard) async {
    try {
      _flashcardsBeingDeleted.add(flashcard);
      await _deleteFlashcardUseCase(flashcard);
      showMessage('Flashcard deletado com sucesso');
    } catch(_) {
      showMessage('Erro ao deletar flashcard');
    } finally {
      _flashcardsBeingDeleted.remove(flashcard);
    }
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }
  }
}
