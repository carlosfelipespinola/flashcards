
import 'package:flashcards/ui/widgets/category_list.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/category.dart';
import '../../widgets/category_form.dart';

class CategoriesManagerPage extends StatefulWidget {
  @override
  _CategoriesManagerPageState createState() => _CategoriesManagerPageState();
}

class _CategoriesManagerPageState extends State<CategoriesManagerPage> {
  GlobalKey<CategoryListState> _categoryListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorias'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CategoryList(
          key: _categoryListKey,
          onCategoryTap: (category) => showCategoryActionsBottomDialog(category),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showCategoryFormBottomDialog(null),
      ),
    );
  }

  void showCategoryActionsBottomDialog(Category category) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Text(category.name, style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),)),
              SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {}, 
                    icon: Icon(Icons.delete), label: Text('Delete'.toUpperCase())
                  ),
                  SizedBox(width: 12,),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {}, 
                    icon: Icon(Icons.edit), label: Text('Edit'.toUpperCase())
                  )
                ],
              )
            ],
          )
        );
      }
    );
  }

  void showCategoryFormBottomDialog(Category? category) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CategoryForm(
            category: category,
            autoFocus: true,
            onCategorySaved: (category) {
              if (_categoryListKey.currentState != null) {
                _categoryListKey.currentState!.fetchCategories();
              }
              if (ModalRoute.of(context)!.isCurrent) {
                Navigator.of(context).pop(category);
              }
            },
          ),
        );
      }
    );
  }
}