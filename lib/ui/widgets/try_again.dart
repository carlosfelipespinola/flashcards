import 'package:flashcards/my_app_localizations.dart';
import 'package:flutter/material.dart';


class TryAgain extends StatelessWidget {

  final String message;
  final Function() onPressed;

  const TryAgain({Key? key, required this.message, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center,),
          SizedBox(height: 12,),
          ElevatedButton.icon(
            label: Text(MyAppLocalizations.of(context).tryAgain),
            icon: Icon(Icons.refresh),
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}