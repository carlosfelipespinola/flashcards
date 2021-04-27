import 'package:flashcards/domain/models/category.dart';
import 'package:flashcards/domain/usecases/save_category.usecase.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;
  final Function(Category)? onCategorySaved;
  final bool autoFocus;

  const CategoryForm({Key? key, this.category, this.onCategorySaved, this.autoFocus = false}) : super(key: key);
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

enum CategoryFormSaveState { unitialized, pending, error, success }

class _CategoryFormState extends State<CategoryForm> {
  SaveCategoryUseCase saveCategoryUseCase = GetIt.I();
  final _formKey = GlobalKey<FormState>();
  var isValid = false;
  var state = CategoryFormSaveState.unitialized;
  var _name = '';
  late Category category;


  @override
  void initState() {
    category = widget.category?.copyWith() ?? Category(name: '');
    _name = category.name;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryForm oldWidget) {
    if (oldWidget.category?.id != widget.category?.id) {
      category = widget.category?.copyWith() ?? Category(name: '');
      _name = category.name;
      _formKey.currentState?.reset();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: state == CategoryFormSaveState.pending,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: widget.autoFocus,
              initialValue: _name,
              onChanged: (value) {
                setState(() { _name = value; });
                validate();
              },
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 8),
            if (state == CategoryFormSaveState.error) ...[
              Text('Algo deu errado, tente novamente', style: TextStyle(color: Theme.of(context).errorColor)),
              SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: canSave ? submit : null,
              child: Text('Salvar'.toUpperCase())
            )
          ],
        ),
      ),
    );
  }

  void submit() async {
    setState(() { state = CategoryFormSaveState.pending; });
    try {
      category = await saveCategoryUseCase(category.copyWith(name: _name));
      setState(() { state = CategoryFormSaveState.success; });
      if (widget.onCategorySaved != null) {
        widget.onCategorySaved!(category);
      }
    } catch(error) {
      setState(() { state = CategoryFormSaveState.error; });
    }
  }

  bool get canSave => hasChanges && isValid && isNotSaving;

  bool get isNotSaving => state != CategoryFormSaveState.pending;

  bool get hasChanges => _name != category.name;

  void validate() {
    setState(() {
      isValid = _name.length > 0;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}