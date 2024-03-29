// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class CategoryFilter {
  Category category;
  bool isUncategorized;

  CategoryFilter._({
    required this.category,
    required this.isUncategorized,
  });

  factory CategoryFilter.uncategorized() =>
      CategoryFilter._(category: Category(name: "null", id: null), isUncategorized: true);
  factory CategoryFilter.category(Category category) => CategoryFilter._(category: category, isUncategorized: false);

  @override
  bool operator ==(covariant CategoryFilter other) {
    if (identical(this, other)) return true;

    return other.category.id == category.id &&
        other.category.name == category.name &&
        other.category.flashcardsCount == other.category.flashcardsCount &&
        other.isUncategorized == isUncategorized;
  }

  @override
  int get hashCode => category.hashCode ^ isUncategorized.hashCode;
}

class FlashcardsGrid extends StatefulWidget {
  final String? searchFilter;
  final CategoryFilter? categoryFilter;
  final bool groupByCategory;
  final Function(Category?)? showAllOfCategoryTap;

  /// [numberOfRowsPerCategory] limit the number of
  /// flashcards shown per category to make the nubmer of rows
  /// match this value.
  ///
  /// Note that this parameter is only applied if there is at least 2 categories
  final int? numberOfRowsPerCategory;
  final void Function()? onScrollBottomEnter;
  final void Function()? onScrollBottomExit;

  const FlashcardsGrid(
      {Key? key,
      this.onScrollBottomEnter,
      this.onScrollBottomExit,
      this.searchFilter,
      this.categoryFilter,
      this.groupByCategory = true,
      this.showAllOfCategoryTap,
      this.numberOfRowsPerCategory})
      : super(key: key);

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

  bool get _isScrollAtBottom =>
      _scrollController.hasClients && _scrollController.position.atEdge && _scrollController.position.pixels != 0;

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
    if (oldWidget.searchFilter != widget.searchFilter || oldWidget.categoryFilter != widget.categoryFilter) {
      fetchFlashcards();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _flashcards = [];
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
      setState(() {
        _fetchState = _FlashcardFetchState.pending;
      });
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
        child: TryAgain(message: MyAppLocalizations.of(context).defaultErrorMessage, onPressed: fetchFlashcards),
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

    bool shouldGroupByCategory = widget.groupByCategory && widget.categoryFilter == null;

    if (shouldGroupByCategory) {
      return _buildFlashcardsGroupedByCategory(context);
    }
    if (widget.categoryFilter != null) {
      var category = _flashcardsGroupedByCategory.keys
          .firstWhere((category) => category?.id == widget.categoryFilter!.category.id);
      var flashcardsOfFilteredCategory = _flashcardsGroupedByCategory[category] ?? [];
      return _buildFlashcardsGrid(flashcardsOfFilteredCategory);
    } else {
      return _buildFlashcardsGrid(_flashcards, controller: _scrollController);
    }
  }

  Widget _buildFlashcardsGrid(List<Flashcard> flashcards, {ScrollController? controller}) => _FlashcardsGrid(
        controller: controller,
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: false,
        flashcards: flashcards,
        highlightedFlashcard: _hightLightedFlashcard,
        onFlashcardLongPress: showFlashcardBottomDialog,
        maxRows: null,
      );

  Widget _buildFlashcardsGroupedByCategory(BuildContext context) {
    if (_flashcardsGroupedByCategory.keys.length > 1) {
      final _numberOfRowsPerCategory = widget.numberOfRowsPerCategory;
      return ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _flashcardsGroupedByCategory.keys.length,
        itemBuilder: (context, categoryIndex) {
          final category = _flashcardsGroupedByCategory.keys.elementAt(categoryIndex);
          return StickyHeaderBuilder(
              builder: (context, factor) {
                return _buildCategoryAppBar(category, elevation: factor == 1 ? 0.0 : 0.5);
              },
              content: _FlashcardsGrid(
                flashcards: _flashcardsGroupedByCategory.values.elementAt(categoryIndex),
                highlightedFlashcard: _hightLightedFlashcard,
                onFlashcardLongPress: (flashcard) => showFlashcardBottomDialog(flashcard),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                maxRows: _numberOfRowsPerCategory,
                onShowAllTap: () => widget.showAllOfCategoryTap?.call(category),
              ));
        },
      );
    } else {
      var category = _flashcardsGroupedByCategory.keys.first;
      return Stack(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight),
              child: _buildFlashcardsGrid(_flashcardsGroupedByCategory.values.elementAt(0),
                  controller: _scrollController)),
          _buildCategoryAppBar(category, elevation: 0.5)
        ],
      );
    }
  }

  Widget _buildCategoryAppBar(Category? category, {double? elevation}) {
    return Container(
      height: kToolbarHeight,
      child: Opacity(
        opacity: 0.80,
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: elevation,
          title: Text(
            (category?.name ?? MyAppLocalizations.of(context).uncategorized),
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void showFlashcardBottomDialog(Flashcard flashcard) async {
    setState(() {
      _hightLightedFlashcard = flashcard;
    });
    final result = await showModalBottomSheet<String?>(
        context: context,
        builder: (context) {
          return FlashcardDetailsBottomDialog(
              flashcard: flashcard,
              onEdit: () => Navigator.of(context).pop('edit'),
              onDelete: () => Navigator.of(context).pop('delete'));
        });
    if (result == 'edit') {
      setState(() {
        _hightLightedFlashcard = null;
      });
      await Navigator.of(context)
          .pushNamed(RoutesPaths.flashcardEditor, arguments: FlashcardEditorPageArguments(flashcard: flashcard));
      await fetchFlashcards();
    } else if (result == 'delete') {
      showFlashcardDeletionConfirmDialog(flashcard);
    } else {
      setState(() {
        _hightLightedFlashcard = null;
      });
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
                  onCancel: () => Navigator.of(context).pop(false));
            }) ??
        false;
    if (shouldDelete) {
      await deleteFlashcard(flashcard);
    }
    setState(() {
      _hightLightedFlashcard = null;
    });
  }

  Future<void> deleteFlashcard(Flashcard flashcard) async {
    try {
      _flashcardsBeingDeleted.add(flashcard);
      await _deleteFlashcardUseCase(flashcard);
      await fetchFlashcards();
      bool wasScrollAtBottomButThereIsNoMoreScroll = _isScrollAtBottom &&
          !_hasExitedScrollBottom &&
          _scrollController.position.maxScrollExtent <= MediaQuery.of(context).size.height;
      if (wasScrollAtBottomButThereIsNoMoreScroll) {
        _notifyBottomExit();
      }
      showMessage(MyAppLocalizations.of(context).deleteFlashcardSuccessMessage);
    } catch (_) {
      showMessage(MyAppLocalizations.of(context).deleteFlashcardSuccessMessage);
    } finally {
      _flashcardsBeingDeleted.remove(flashcard);
    }
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _FlashcardsGrid extends StatefulWidget {
  _FlashcardsGrid(
      {Key? key,
      required this.physics,
      required this.shrinkWrap,
      required this.flashcards,
      required this.highlightedFlashcard,
      required this.onFlashcardLongPress,
      this.onShowAllTap,
      this.maxRows,
      this.controller})
      : super(key: key);

  final ScrollPhysics physics;
  final bool shrinkWrap;
  final List<Flashcard> flashcards;
  final Flashcard? highlightedFlashcard;
  final Function(Flashcard) onFlashcardLongPress;
  final int? maxRows;
  final VoidCallback? onShowAllTap;
  final ScrollController? controller;

  @override
  State<_FlashcardsGrid> createState() => _FlashcardsGridState();
}

class _FlashcardsGridState extends State<_FlashcardsGrid> {
  @override
  Widget build(BuildContext context) {
    final maxCardSize = 300;
    final numberOfCardsPerRow = (MediaQuery.of(context).size.width / maxCardSize).ceil();

    if (widget.maxRows == null) {
      return buildGridView(
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          crossAxisCount: numberOfCardsPerRow,
          flashcards: widget.flashcards,
          controller: widget.controller);
    } else {
      return buildTruncatedGridView(
          maxRows: widget.maxRows!, numberOfCardsPerRow: numberOfCardsPerRow, controller: widget.controller);
    }
  }

  Widget buildGridView(
      {required List<Flashcard> flashcards,
      ScrollPhysics? physics,
      required bool shrinkWrap,
      required int crossAxisCount,
      EdgeInsetsGeometry? padding,
      ScrollController? controller}) {
    return GridView.builder(
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding ?? gridPadding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
        itemCount: flashcards.length,
        itemBuilder: (context, index) => flashcardItemBuilder(context, flashcards.elementAt(index)));
  }

  EdgeInsets get gridPadding => EdgeInsets.symmetric(vertical: 8, horizontal: 8);

  Widget buildTruncatedGridView(
      {required int maxRows, required int numberOfCardsPerRow, ScrollController? controller}) {
    final maxFlashcards = maxRows * numberOfCardsPerRow;
    final shouldTruncateList = widget.flashcards.length > maxFlashcards;
    List<Flashcard>? trucatedFlashcards;
    if (shouldTruncateList) {
      trucatedFlashcards = widget.flashcards.sublist(0, maxFlashcards);
    }
    return ListView(
      controller: controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: gridPadding,
      children: [
        buildGridView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: numberOfCardsPerRow,
            flashcards: trucatedFlashcards ?? widget.flashcards,
            padding: EdgeInsets.all(0.0)),
        if (shouldTruncateList) ...[
          SizedBox(
            height: 4,
          ),
          buildShowAllButton()
        ]
      ],
    );
  }

  Widget buildShowAllButton() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                elevation: 0,
                primary: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(127))),
            onPressed: widget.onShowAllTap,
            child: Text(MyAppLocalizations.of(context).showAll.toUpperCase())));
  }

  Widget flashcardItemBuilder(BuildContext context, Flashcard flashcard) {
    final cardShape = Theme.of(context).cardTheme.shape;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: widget.highlightedFlashcard == flashcard
            ? BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: cardShape is RoundedRectangleBorder ? cardShape.borderRadius : null)
            : null,
        child: FlashcardTile(
          maxSize: constraints.maxWidth,
          size: constraints.maxWidth,
          flashcard: flashcard,
          onLongPress: () => widget.onFlashcardLongPress(flashcard),
        ),
      );
    });
  }
}
