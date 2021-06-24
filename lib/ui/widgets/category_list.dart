import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/models/category.dart';
import '../../domain/usecases/find_categories.usecase.dart';
import 'try_again.dart';

class CategoryList extends StatefulWidget {

  final Function(Category)? onCategoryTap;
  final Widget Function(Category)? categoryBuilder;

  const CategoryList({Key? key, this.onCategoryTap, this.categoryBuilder}) : super(key: key);

  @override
  CategoryListState createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList> {
  final FindCategoriesUseCase _findCategoriesUseCase = GetIt.I();
  late Future<List<Category>> _categories;

  @override
  void initState() {
    _categories = _findCategoriesUseCase();
    super.initState();
  }

  void fetchCategories() {
    setState(() {
      _categories = _findCategoriesUseCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: TryAgain(
              message: 'Ocorreu um erro, tente novamente!',
              onPressed: fetchCategories
            ),
          );
        }
        if (snapshot.requireData.isEmpty) {
          return Center(
            child: Text('Você ainda não tem nenhuma categoria cadastrada'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.requireData.length,
          itemBuilder: (context, index) {
            final category = snapshot.requireData.elementAt(index);
            if (widget.categoryBuilder != null) {
              return widget.categoryBuilder!(category);
            }
            return categoryBuilder(category);
          },
        );
      },
    );
  }

  Widget categoryBuilder(Category category) {
    return Card(
      child: ListTile(
        onTap: () {
          if (widget.onCategoryTap != null) {
            widget.onCategoryTap!(category);
          }
        },
        title: Text(category.name, style: Theme.of(context).textTheme.subtitle2),
      ),
    );
  }
}