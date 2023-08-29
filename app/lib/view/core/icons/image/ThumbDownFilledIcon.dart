import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for a filled thumb down
class ThumbDownFilledIcon extends StatelessWidget {
  final double? _size;
  final Color? _color;

  /// Creates a new filled thumb down icon.
  const ThumbDownFilledIcon({super.key, double size = 24, Color? color})
      : _size = size,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/image/thumb_down_filled.svg',
      width: _size,
      height: _size,
      colorFilter: ColorFilter.mode(
          _color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
