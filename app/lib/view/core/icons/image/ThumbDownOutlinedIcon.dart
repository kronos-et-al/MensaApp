import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for a thumb down
class ThumbDownOutlinedIcon extends StatelessWidget {
  final double? _size;
  final Color? _color;

  /// Creates a new thumb down icon.
  /// @param key The key to identify this widget.
  /// @param size The size of the icon.
  /// @param color The color of the icon.
  /// @return a widget that displays the icon for a thumb down
  const ThumbDownOutlinedIcon({super.key, double size = 24, Color? color})
      : _size = size,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/image/thumb_down_outlined.svg',
      width: _size,
      height: _size,
      colorFilter: ColorFilter.mode(
          _color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
