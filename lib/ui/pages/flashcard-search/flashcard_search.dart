import 'package:flashcards/ui/widgets/flashcards_grid.dart';
import 'package:flutter/material.dart';

class FlashcardSearch extends SearchDelegate {

  @override
  String? get searchFieldLabel => 'Pesquisar';
  
  @override
  List<Widget> buildActions(BuildContext context) => [];

  @override
  Widget buildLeading(BuildContext context) => BackButton();

  @override
  Widget buildResults(BuildContext context) {
    return _build(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _build(context);
  }

  Widget _build(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return FlashcardsGrid(groupByCategory: false, searchFilter: query);
  }
  
}