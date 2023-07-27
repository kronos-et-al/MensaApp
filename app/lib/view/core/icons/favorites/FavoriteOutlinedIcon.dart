import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for Wheat
class FavoriteOutlinedIcon extends StatelessWidget {
  final double? _size;
  final Color? _color;

  const FavoriteOutlinedIcon({super.key, double size = 24, Color? color})
      : _size = size,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/favorites/favorite_outlined.svg',
      width: _size,
      height: _size,
      colorFilter: ColorFilter.mode(
          _color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
