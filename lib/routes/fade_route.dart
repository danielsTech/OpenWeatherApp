import 'package:flutter/material.dart';

class CustomPageRouteFade<T> extends PageRoute<T> {
  CustomPageRouteFade(this.child);

  @override
  // TODO: implement barrierColor
  Color get barrierColor => Colors.black;

  @override
  String get barrierLabel => null;

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => Duration(milliseconds: 450);
}