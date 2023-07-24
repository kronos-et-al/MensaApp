import 'package:flutter/material.dart';

class MensaTapable extends StatelessWidget {

  final Widget _child;
  final Color? _color;
  final Function() _onTap;

  MensaTapable({super.key, required Widget child, Color? color, required Function() onTap}) : _child = child, _color = color, _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _color ?? Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: _onTap,
        child: _child,
      ),
    );
  }





}