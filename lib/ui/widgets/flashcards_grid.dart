import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/models/fashcard.dart';
import 'package:flashcards/domain/usecases/delete_flashcard.usecase.dart';
import 'package:flashcards/domain/usecases/find_flashcards.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/router.dart';
import 'package:flashcards/ui/pages/flashcard-editor/flashcard_editor.page.arguments.dart';
import 'package:flashcards/ui/widgets/confirm_bottom_dialog.dart';
import 'package:flashcards/ui/widgets/flashcard.dart';
import 'package:flashcards/ui/widgets/try_again.dart';

import 'flashcard_details_bottom_dialog.dart';

class FlashcardsGrid extends StatefulWidget {
  final String? searchFilter;
  final bool groupByCategory;
  /// [numberOfRowsPerCategory] limit the number of
  /// flashcards shown per category to make the nubmer of rows
  /// match this value.
  /// 
  /// Note that this parameter is only applied if there is at least 2 categories
  final int? numberOfRowsPerCategory;
  final void Function()? onScrollBottomEnter;
  final void Function()? onScrollBottomExit;

  const FlashcardsGrid({
    Key? key,
    this.onScrollBottomEnter,
    this.onScrollBottomExit,
    this.searchFilter,
    this.groupByCategory = true,
    this.numberOfRowsPerCategory
  }) : super(key: key);

  @override
  FlashcardsGridState createState() => FlashcardsGridState();
}

enum _FlashcardFetchState { pending, error, success }

class FlashcardsGridState extends State<FlashcardsGrid> {

  final FindFlashcardsUseCase _findFlashcardsUseCase = GetIt.I();
  final DeleteFlashcardUseCase _deleteFlashcardUseCase = GetIt.I();

  List<Flashcard> _flashcards = [];

  _FlashcardFetchState _fetchState = _FlashcardFetchState.pending;

  Set<Flashcard> _flashcardsBeingDeleted = {};

  late ScrollController _scrollController;

  late bool _hasExitedScrollBottom;

  bool get _isScrollAtBottom =>_scrollController.hasClients && _scrollController.position.atEdge && _scrollController.position.pixels != 0;

  Flashcard? _hightLightedFlashcard;

  Map<Category?, List<Flashcard>> get _flashcardsGroupedByCategory {
    final map = groupBy<Flashcard, Category?>(_flashcards, (flashcard) {
      return flashcard.category;
    });
    final sortedMapEntries = map.entries.sorted((a, b) {
      if (a.key == null) return 1;
      if (b.key == null) return -1;
      return a.key!.name.toLowerCase().compareTo(b.key!.name.toLowerCase());
    });
    return Map.fromEntries(sortedMapEntries);
  }

  @override
  void initState() {
    _scrollController = ScrollController(debugLabel: 'flashcards-grid-scroll');
    _scrollController.addListener(_onScroll);
    _hasExitedScrollBottom = !_isScrollAtBottom;
    fetchFlashcards();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlashcardsGrid oldWidget) {
    if (oldWidget.searchFilter != widget.searchFilter) {
      fetchFlashcards();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrollAtBottom) {
      _notifyBottomEnter();
    } else if (!_hasExitedScrollBottom) {
      _notifyBottomExit();
    }
  }

  void _notifyBottomEnter() {
    widget.onScrollBottomEnter?.call();
    _hasExitedScrollBottom = false; 
  }

  void _notifyBottomExit() {
    _hasExitedScrollBottom = true;
    widget.onScrollBottomExit?.call();
  }

  Future<void> fetchFlashcards() async {
    try {
      late final List<Flashcard> response;
      setState(() { _fetchState = _FlashcardFetchState.pending; });
      response = await _findFlashcardsUseCase.call(searchTerm: widget.searchFilter);
      setState(() {
        _flashcards = response;
        _fetchState = _FlashcardFetchState.success;
      });
    } catch (error) {
      setState(() {
        _fetchState = _FlashcardFetchState.error;
      });
    }
    // This is required to prevent unexpected behaviour with sticky headers
    WidgetsBinding.instance?.endOfFrame.then((_) {
      setState(() {});
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
    if (_fetchState == _FlashcardFetchState.pending && _flashcards.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (_fetchState == _FlashcardFetchState.error) {
      return Center(
        child: TryAgain(
          message: MyAppLocalizations.of(context).defaultErrorMessage,
          onPressed: fetchFlashcards
        ),
      );
    }
    if (_flashcards.isEmpty && widget.searchFilter != null && widget.searchFilter!.isNotEmpty) {
      return Center(
        child: Text(MyAppLocalizations.of(context).noFlashcardForSearchMessage),
      );
    } else if (_flashcards.isEmpty) {
      return Center(
        child: Text(MyAppLocalizations.of(context).noFlashcardCreatedMessage),
      );
    }
    if (widget.groupByCategory) {
      final _mapCategoryFlashcards = _flashcardsGroupedByCategory;
      final _numberOfRowsPerCategory = _mapCategoryFlashcards.keys.length > 1 ? widget.numberOfRowsPerCategory : null;
      return RefreshIndicator(
        onRefresh: () async => fetchFlashcards(),
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _mapCategoryFlashcards.keys.length,
          itemBuilder: (context, categoryIndex) {
            final category = _mapCategoryFlashcards.keys.elementAt(categoryIndex);
            return StickyHeaderBuilder(
              builder: (context, factor) {
                return Container(
                  height: kToolbarHeight,
                  child: Opacity(
                    opacity: 0.80,
                    child: AppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: factor == 1 ? 0.0 : 0.5,
                      title: Text(
                        category?.name ?? MyAppLocalizations.of(context).uncategorized,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
              content: _FlashcardsGrid(
                flashcards: _mapCategoryFlashcards.values.elementAt(categoryIndex),
                highlightedFlashcard: _hightLightedFlashcard,
                onFlashcardLongPress: (flashcard) => showFlashcardBottomDialog(flashcard),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                rows: _numberOfRowsPerCategory,
              )
            );
          },
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async => fetchFlashcards(),
        child: _FlashcardsGrid(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: false,
          flashcards: _flashcards,
          highlightedFlashcard: _hightLightedFlashcard,
          onFlashcardLongPress: showFlashcardBottomDialog,
          rows: null,
        ),
      );
    }
    
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
      await fetchFlashcards();
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
          title: "${MyAppLocalizations.of(context).delete} ${MyAppLocalizations.of(context).flashcard}",
          text: MyAppLocalizations.of(context).deleteFlashcardConfirmMessage,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false)
        );
      }
    ) ?? false;
    if (shouldDelete) {
      await deleteFlashcard(flashcard);
    }
    setState(() { _hightLightedFlashcard = null; });
  }

  Future<void> deleteFlashcard(Flashcard flashcard) async {
    try {
      _flashcardsBeingDeleted.add(flashcard);
      await _deleteFlashcardUseCase(flashcard);
      await fetchFlashcards();
      bool wasScrollAtBottomButThereIsNoMoreScroll = 
        _isScrollAtBottom &&
        !_hasExitedScrollBottom &&
        _scrollController.position.maxScrollExtent <= MediaQuery.of(context).size.height;
      if (wasScrollAtBottomButThereIsNoMoreScroll) {
        _notifyBottomExit();
      }
      showMessage(MyAppLocalizations.of(context).deleteFlashcardSuccessMessage);
    } catch(_) {
      showMessage(MyAppLocalizations.of(context).deleteFlashcardSuccessMessage);
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

class _FlashcardsGrid extends StatefulWidget {

  _FlashcardsGrid({
    Key? key,
    required this.physics,
    required this.shrinkWrap,
    required this.flashcards,
    required this.highlightedFlashcard,
    required this.onFlashcardLongPress,
    this.rows
  }) : super(key: key);

  final ScrollPhysics physics;
  final bool shrinkWrap;
  final List<Flashcard> flashcards;
  final Flashcard? highlightedFlashcard;
  final Function(Flashcard) onFlashcardLongPress;
  final int? rows;

  @override
  State<_FlashcardsGrid> createState() => _FlashcardsGridState();
}

class _FlashcardsGridState extends State<_FlashcardsGrid> {

  bool _ignoreCardsLimit = false;

  @override
  Widget build(BuildContext context) {
    final maxCardSize = 300;
    final numberOfCardsPerRow = (MediaQuery.of(context).size.width / maxCardSize).ceil();
    if (widget.rows != null && !_ignoreCardsLimit && widget.flashcards.length > (widget.rows! * numberOfCardsPerRow)) {
      final sublist = widget.flashcards.sublist(0, widget.rows! * numberOfCardsPerRow);
      return ListView(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: gridPadding,
        children: [
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: numberOfCardsPerRow),
            itemCount: sublist.length,
            itemBuilder: (context, index) {
              final flashcard = sublist.elementAt(index);
              return flashcardItemBuilder(context, flashcard);
            }
          ),
          SizedBox(height: 4,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                elevation: 0,
                primary: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(127))
              ),
              onPressed: () => setState(() => _ignoreCardsLimit = true),
              child: Text(MyAppLocalizations.of(context).showAll.toUpperCase())
            ),
          )
        ],
      );
    } else {
      return GridView.builder(
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: gridPadding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: numberOfCardsPerRow),
        itemCount: widget.flashcards.length,
        itemBuilder: (context, index) => flashcardItemBuilder(
          context,
          widget.flashcards.elementAt(index)
        )
      );
    }
    
  }

  EdgeInsets get gridPadding => EdgeInsets.symmetric(vertical: 8, horizontal: 8);

  Widget flashcardItemBuilder (BuildContext context, Flashcard flashcard) {
    final cardShape = Theme.of(context).cardTheme.shape;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: widget.highlightedFlashcard == flashcard ? BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
            borderRadius: cardShape is RoundedRectangleBorder ? cardShape.borderRadius : null
          ) : null,
          child: FlashcardTile(
            maxSize: constraints.maxWidth, 
            size: constraints.maxWidth,
            flashcard: flashcard,
            onLongPress: () => widget.onFlashcardLongPress(flashcard),
          ),
        );
      }
    );
  }
}
