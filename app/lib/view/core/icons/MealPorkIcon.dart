import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for Pork
class MealPorkIcon extends StatelessWidget {
  final double _width;
  final double _height;

  /// This widget is used to display the icon for Pork
  /// @param key is the key for this widget
  /// @param width is the width of the icon
  /// @param height is the height of the icon
  /// @returns a widget that displays the icon for Pork
  const MealPorkIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset('assets/icons/pork.svg',
            width: _width - 4, height: _height - 4));
  }
}
