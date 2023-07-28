import 'package:flutter/material.dart';

/// This widget is used to display a tapable button.
class MensaTapable extends StatelessWidget {
  final Widget _child;
  final Color? _color;
  final Function() _onTap;
  final Function()? _onLongPress;

  /// Creates a tapable button.
  /// @param key The key to use for this widget.
  /// @param child The child of the button.
  /// @param color The color of the button.
  /// @param onTap The function to call when the icon is tapped.
  /// @param onLongPress The function to call when the icon is long pressed.
  /// @returns a widget that displays a tapable icon
  const MensaTapable(
      {super.key,
      required Widget child,
      Color? color,
      required Function() onTap,
      Function()? onLongPress})
      : _child = child,
        _color = color,
        _onTap = onTap,
        _onLongPress = onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _color ?? Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: _child,
      ),
    );
  }
}
