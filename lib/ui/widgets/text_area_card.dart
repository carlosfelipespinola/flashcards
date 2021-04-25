
import 'package:flutter/material.dart';

class TextAreaCard extends StatelessWidget {

  final Function(String)? onChange;
  final TextEditingController? controller;
  final String label;
  final bool readOnly;
  final bool enabled;
  final bool enableInteractiveSelection;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final TextInputAction? textInputAction;
  final double? elevation;
  final int? maxLength;

  TextAreaCard({
    Key? key,
    this.controller,
    required this.label,
    this.onChange,
    this.onEditingComplete,
    this.elevation,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.enableInteractiveSelection = true,
    this.maxLength
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Card(
        elevation: this.elevation,
        margin: EdgeInsets.all(0),
        borderOnForeground: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            focusNode: focusNode,
            readOnly: readOnly,
            controller: controller,
            onChanged: onChange,
            onEditingComplete: onEditingComplete,
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            maxLength: readOnly ? null : maxLength,
            decoration: InputDecoration(
              contentPadding:EdgeInsets.all(16.0),
              labelText: label,
              floatingLabelBehavior:FloatingLabelBehavior.auto,
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              alignLabelWithHint: true,
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: textInputAction,
            maxLines: null,
            minLines: null,
            expands: true,

          ),
        ),
      ),
    );
  }
}
