// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/ui/widgets/flashcards_grid.dart';

class FlashcardsOfCategoryPageArguments {
  final Category? category;
  FlashcardsOfCategoryPageArguments({
    this.category,
  });
}

class FlashcardsOfCategory extends StatelessWidget {
  final FlashcardsOfCategoryPageArguments arguments;
  const FlashcardsOfCategory({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments.category?.name ?? "Uncategorized"),
      ),
      body: SafeArea(
          child: FlashcardsGrid(
        groupByCategory: false,
        categoryFilter:
            arguments.category == null ? CategoryFilter.uncategorized() : CategoryFilter.category(arguments.category!),
        numberOfRowsPerCategory: 2,
      )),
    );
  }
}
