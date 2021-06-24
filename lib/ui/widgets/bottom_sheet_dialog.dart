import 'package:flutter/material.dart';

class BottomSheetDialog extends StatelessWidget {

  final Widget child;
  final EdgeInsets? padding;

  const BottomSheetDialog({Key? key, this.padding, required this.child}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
      padding: padding,
    );
  }
}