
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
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 32.0, left: 16.0),
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
                child: Text('Cancelar'.toUpperCase(), style: TextStyle(color: Theme.of(context).errorColor),),
                onPressed: onCancel
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                child: Text('Confirmar'.toUpperCase(), textAlign: TextAlign.center,),
                onPressed: onConfirm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}