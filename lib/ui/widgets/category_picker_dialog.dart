import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/find_categories.usecase.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
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
  late SaveCategoryUseCase saveCategoryUseCase;

  @override
  void initState() {
    findCategoriesUseCase = GetIt.I.get<FindCategoriesUseCase>();
    saveCategoryUseCase = GetIt.I.get<SaveCategoryUseCase>();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 62,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(25.0)
              ),
            ),
          ),
          TabBar(
            tabs: [
              Tab(text: 'Select category',),
              Tab(text: 'Create category',)
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: TabBarView(
              children: [
                FutureBuilder<List<Category>>(
                  future: findCategoriesUseCase(),
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
                    if (snapshot.requireData.length == 0) {
                      return Center(child: Text('Você ainda não tem nenhuma categoria cadastrada'),);
                    }
                    return ListView.builder(
                      itemCount: snapshot.requireData.length,
                      itemBuilder: (context, index) {
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: CategoryForm(
                      onCategorySaved: (category) {
                        if (ModalRoute.of(context)!.isCurrent) {
                          Navigator.of(context).pop(category);
                        }
                      },
                    )
                  ),
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}