import 'package:flashcards/domain/models/category.dart';
import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {
  final Category category;

  const CategoryForm({Key? key, required this.category}) : super(key: key);
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {


  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextField(),
          ElevatedButton(
            onPressed: () {},
            child: Text('Salvar'.toUpperCase())
          )
        ],
      ),
    );
  }
}