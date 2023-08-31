import 'package:flutter/material.dart';

class Handle extends StatelessWidget {
  const Handle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 8,
      decoration: BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(25.0)),
    );
  }
}
