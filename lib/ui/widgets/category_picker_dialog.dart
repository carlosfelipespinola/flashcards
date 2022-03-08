import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/find_categories.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/ui/widgets/bottom_sheet_dialog.dart';
import 'package:flashcards/ui/widgets/category_form.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoryPickerDialog extends StatefulWidget {
  final Category? selectedCategory;

  const CategoryPickerDialog({Key? key, this.selectedCategory}) : super(key: key);
  @override
  _CategoryPickerDialogState createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<CategoryPickerDialog> {
  late FindCategoriesUseCase findCategoriesUseCase;
  late Future<List<Category>> findCategoriesFuture;
  bool isShowingListOfCategories = true;

  @override
  void initState() {
    findCategoriesUseCase = GetIt.I.get<FindCategoriesUseCase>();
    findCategoriesFuture = findCategoriesUseCase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: findCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        }
        if (snapshot.hasError) {
          return Center(child: Text(MyAppLocalizations.of(context).defaultErrorMessage),);
        }
        if (!snapshot.hasData) {
          return Container();
        }
        if (isShowingListOfCategories && snapshot.requireData.length == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 64.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text(MyAppLocalizations.of(context).noCategoryRegisteredMessage),),
                SizedBox(height: 12,),
                buildCreateCategoryButton()
              ],
            ),
          );
        }
        if (isShowingListOfCategories) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 0.6,
            builder: (context, scrollController) => Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Scrollbar(
                    controller: scrollController,
                    isAlwaysShown: true,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      controller: scrollController,
                      itemCount: snapshot.requireData.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return SizedBox(height: 16,);
                        final category = snapshot.requireData.elementAt(index - 1);
                        return ListTile(
                          minVerticalPadding: 4,
                          title: Text(category.name),
                          trailing: widget.selectedCategory?.id == category.id ? Icon(Icons.check) : null,
                          onTap: () {
                            final isThisCategorySelected = widget.selectedCategory?.id == category.id;
                            if (isThisCategorySelected) {
                              Navigator.of(context).pop(null);
                            } else {
                              Navigator.of(context).pop(category);
                            }
                          },
                        );
                      }
                    ),
                  ),
                ),
                buildCreateCategoryButton(),
              ],
            ),
          );
        }
        return BottomSheetDialog(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: SingleChildScrollView(
            child: CategoryForm(
              autoFocus: true,
              onCategorySaved: (category) {
                if (ModalRoute.of(context)!.isCurrent) {
                  Navigator.of(context).pop(category);
                }
              },
            )
          ),
        );
      }
    );
  }

  Widget buildCreateCategoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            isShowingListOfCategories = false;
          });
        },
        icon: Icon(Icons.add), 
        label: Text(MyAppLocalizations.of(context).createCategory.toUpperCase())
      ),
    );
  }
}