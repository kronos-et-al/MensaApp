import 'package:flutter/material.dart';

/// This widget is used to display a tapable button.
class MensaTapable extends StatelessWidget {
  final Widget _child;
  final Color? _color;
  final Function() _onTap;
  final Function()? _onLongPress;
  final String _semanticLabel;

  /// Creates a tapable button.
  const MensaTapable(
      {super.key,
      required Widget child,
      Color? color,
      required Function() onTap,
      Function()? onLongPress,
      required String semanticLabel})
      : _child = child,
        _color = color,
        _onTap = onTap,
        _onLongPress = onLongPress,
        _semanticLabel = semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
        button: true,
        label: _semanticLabel,
        child: Material(
          color: _color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: _child,
          ),
        ));
  }
}
