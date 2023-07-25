import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the exceptions icon for an error
class ErrorExceptionIcon extends StatelessWidget {
  final double _size;
  final Color? _color;

  /// Creates an error icon.
  /// @param key The key to use for this widget.
  /// @param size The size of the icon.
  /// @param color The color of the icon.
  /// @returns a widget that displays the icon for an error
  const ErrorExceptionIcon({super.key, double size = 24, Color? color})
      : _size = size,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/exceptions/error.svg',
      width: _size,
      height: _size,
      colorFilter: ColorFilter.mode(
          _color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
