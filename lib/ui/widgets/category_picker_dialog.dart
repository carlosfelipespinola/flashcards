import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/find_categories.usecase.dart';
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder<List<Category>>(
        future: findCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasError) {
            return Center(child: Text('Algo deu errado, tente novamente mais tarde!'),);
          }
          if (!snapshot.hasData) {
            return Container();
          }
          if (isShowingListOfCategories && snapshot.requireData.length == 0) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text('Você ainda não tem nenhuma categoria cadastrada'),),
                SizedBox(height: 12,),
                createCategoryButton
              ],
            );
          }
          if (isShowingListOfCategories) {
            return ListView.builder(
              itemCount: snapshot.requireData.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.requireData.length) {
                  return createCategoryButton;
                }
                final category = snapshot.requireData.elementAt(index);
                return ListTile(
                  title: Text(category.name),
                  trailing: widget.selectedCategory?.id == category.id ? Icon(Icons.check) : null,
                  onTap: () {
                    if (widget.selectedCategory?.id != category.id) {
                      Navigator.of(context).pop(category);
                    }
                  },
                );
              }
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: SingleChildScrollView(
              child: CategoryForm(
                onCategorySaved: (category) {
                  if (ModalRoute.of(context)!.isCurrent) {
                    Navigator.of(context).pop(category);
                  }
                },
              )
            ),
          );
        }
      ),
    );
  }

  Widget get createCategoryButton {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            isShowingListOfCategories = false;
          });
        },
        icon: Icon(Icons.add), 
        label: Text('Criar Nova categoria'.toUpperCase())
      ),
    );
  }
}