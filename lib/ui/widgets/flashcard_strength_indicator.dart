import 'package:flutter/material.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

class FlashcardStrengthIndicator extends StatelessWidget {

  /// [value] must be an integer between 1 and 5 (inclusive) 
  final int value;

  const FlashcardStrengthIndicator({ Key? key, required this.value }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignalStrengthIndicator.bars(
      levels: <num, Color>{
        0: Colors.red,
        20: Colors.orange[600]!,
        40: Colors.yellow[700]!,
        60: Colors.lightGreen,
        80: Colors.green
      },
      barCount: 5,
      minValue: 0,
      maxValue: 100,
      value: value * 20
    );
  }
}