
import 'package:flashcards/my_app_localizations.dart';
import 'package:flutter/material.dart';

class ConfirmBottomDialog extends StatelessWidget {
  final String title;
  final String text;
  final void Function() onConfirm;
  final void Function() onCancel;

  const ConfirmBottomDialog({
    Key? key,
    required this.title,
    required this.text,
    required this.onConfirm,
    required this.onCancel
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16.0),
          Text(text, style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w600),),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: Text(
                  MyAppLocalizations.of(context).cancel.toUpperCase(),
                  style: TextStyle(color: Theme.of(context).errorColor)
                ),
                onPressed: onCancel
              ),
              SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                child: Text(
                  MyAppLocalizations.of(context).confirm.toUpperCase(),
                  textAlign: TextAlign.center
                ),
                onPressed: onConfirm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}