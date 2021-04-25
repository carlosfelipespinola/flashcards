import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/ui/widgets/category_picker_dialog.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  final Category? selectedCategory;
  final void Function(Category) onChange;

  const CategoryPicker({Key? key, this.selectedCategory, required this.onChange}) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: ListTile(
        title: Text('Category', style: Theme.of(context).textTheme.caption,),
        subtitle: Text(widget.selectedCategory?.name ?? 'No category selected', style: Theme.of(context).textTheme.subtitle1),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: () {
          showCategoryPicker(context, widget.selectedCategory);
        },
      ),
    );
  }

  void showCategoryPicker(BuildContext context, Category? selectedCategory) async {
    Category? category = await showModalBottomSheet<Category?>(
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0))
      ),
      context: context, 
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(top: 40),
          child: CategoryPickerDialog(selectedCategory: selectedCategory,));
      }
    );
    if (category != null) {
      widget.onChange(category);
    }
  }
}