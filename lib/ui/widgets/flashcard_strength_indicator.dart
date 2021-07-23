import 'package:flutter/material.dart';

class FlashcardStrengthIndicator extends StatelessWidget {

  /// [value] must be an integer between 1 and 5 (inclusive) 
  final int value;

  const FlashcardStrengthIndicator({ Key? key, required this.value }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 44,
        height: 16,
        child: LinearProgressIndicator(
          value: value / 5,
          backgroundColor: Colors.indigo[100],
          valueColor: AlwaysStoppedAnimation<Color>(colorByValue),
        ),
      ),
    );
  }

  Color get colorByValue {
    final levels = <num, Color>{
      1: Colors.red,
      2: Colors.orange[600]!,
      3: Colors.yellow[700]!,
      4: Colors.lightGreen,
      5: Colors.green
    };
    return levels[value]!;
  }
}
