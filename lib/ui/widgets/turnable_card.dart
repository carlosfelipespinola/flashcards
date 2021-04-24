

import 'dart:math';

import 'package:flutter/material.dart';

class TurnableCard extends StatefulWidget {

  final Widget Function(BuildContext context, bool isShowingFront) builder;
  final double size;
  final double maxSize;
  final void Function(bool isShowingFront)? onTurned;
  final void Function()? longPress;

  const TurnableCard({
    Key? key,
    required this.builder,
    this.onTurned,
    required this.size,
    required this.maxSize,
    this.longPress
  }) : super(key: key);
  
  @override
  TurnableCardState createState() => TurnableCardState();
}

class TurnableCardState extends State<TurnableCard> with SingleTickerProviderStateMixin  {

  late AnimationController _animationController;

  late Animation<double> _animation;

  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  bool _isShowingFront = true;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = Tween<double>(begin: 0, end: 1)
      .animate(_animationController)
      ..addListener(this.onAnimationChange)
      ..addStatusListener(this.onAnimationStatusChange);
    super.initState();
  }

  void onAnimationChange() {
    setState(() {
      if ( _animation.value >= 0.5 ) {
        _isShowingFront = false;
      } else {
        _isShowingFront = true;
      }
    });
  }

  void onAnimationStatusChange(AnimationStatus status) {
    setState(() {
      _animationStatus = status;
      if ( widget.onTurned != null ) {
        if ( _animationStatus == AnimationStatus.completed ||  _animationStatus == AnimationStatus.dismissed  ) {
          widget.onTurned!(_isShowingFront);
        }
      }
    });
  }

  void restore() {
    _animationController.reset();
    setState(() {
      _isShowingFront = true;
      _animationStatus = AnimationStatus.dismissed;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _normalizedSize {
    return widget.size < widget.maxSize ? widget.size : widget.maxSize;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _normalizedSize,
      height: _normalizedSize,
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateY(pi * _animation.value),
        child: Card(
          child: InkWell(
            onLongPress: widget.longPress,
            onTap: _animationStatus == AnimationStatus.completed || _animationStatus == AnimationStatus.dismissed ? () {

              if (_animationStatus == AnimationStatus.dismissed) {
                _animationController.forward();
              } else if ( _animationStatus == AnimationStatus.completed ) {
                _animationController.reverse();
              }
            } : null,
            child: Transform(
              alignment: FractionalOffset.center,
              transform: (() {
                if ( _animation.value >= 0.5 ) {
                  return Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(pi * -1);
                }
                return Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(0);
              })(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.builder(context, this._isShowingFront)
              ),
            ),
          ),
        ),
      ),
    );
  }
}