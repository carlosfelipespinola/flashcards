
import 'package:flashcards/domain/usecases/delete_category.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/ui/widgets/bottom_sheet_dialog.dart';
import 'package:flashcards/ui/widgets/category_list.dart';
import 'package:flashcards/ui/widgets/confirm_bottom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/models/category.dart';
import '../../widgets/category_form.dart';

class CategoriesManagerPage extends StatefulWidget {
  @override
  _CategoriesManagerPageState createState() => _CategoriesManagerPageState();
}

class _CategoriesManagerPageState extends State<CategoriesManagerPage> {
  GlobalKey<CategoryListState> _categoryListKey = GlobalKey();
  DeleteCategoryUseCase deleteCategoryUseCase = GetIt.I();
  Set<Category> categoriesBeingDeleted = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(MyAppLocalizations.of(context).categories),),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      showCategoryDeleteConfirmDialog(category);
                    }, 
                    icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                    label: Text(
                      MyAppLocalizations.of(context).delete.toUpperCase(),
                      style: TextStyle(color: Theme.of(context).errorColor),
                    )
                  ),
                  SizedBox(width: 12,),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showCategoryFormBottomDialog(category);
                    }, 
                    icon: Icon(Icons.edit),
                    label: Text(MyAppLocalizations.of(context).edit.toUpperCase())
                  )
                ],
              )
            ],
          )
        );
      }
    );
  }

  void showCategoryDeleteConfirmDialog(Category category) async {
    if (cannotDeleteCategory(category)) return;
    final shouldDelete = await showModalBottomSheet<bool?>(
      isScrollControlled: false,
      context: context,
      builder: (context) {
        return ConfirmBottomDialog(
          title: MyAppLocalizations.of(context).delete + ' ' + MyAppLocalizations.of(context).category.toLowerCase(),
          text: MyAppLocalizations.of(context).deleteCategoryConfirmMessage(category.name),
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false)
        );
      }
    ) ?? false;
    if (shouldDelete) {
      await deleteCategory(category);
      _categoryListKey.currentState?.fetchCategories();
    }
  }

  bool cannotDeleteCategory(Category category) {
    return categoriesBeingDeleted.contains(category);
  }

  Future<void> deleteCategory(Category category) async {
    try {
      categoriesBeingDeleted.add(category);
      await deleteCategoryUseCase(category);
      showMessage(MyAppLocalizations.of(context).deleteCategorySuccessMessage(category.name));
    } catch (_) {
      showMessage(MyAppLocalizations.of(context).deleteCategoryErrorMessage(category.name));
    } finally {
      categoriesBeingDeleted.remove(category);
    }
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }
  }

  void showCategoryFormBottomDialog(Category? category) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return BottomSheetDialog(
          padding: const EdgeInsets.all(16.0),
          child: CategoryForm(
            category: category,
            autoFocus: true,
            onCategorySaved: (category) {
              _categoryListKey.currentState?.fetchCategories();
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