import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for animal welfare Beef
class MealBeefAwIcon extends StatelessWidget {
  final double _width;
  final double _height;

  /// This widget is used to display the icon for animal welfare Beef
  /// @param key is the key for this widget
  /// @param width is the width of the icon
  /// @param height is the height of the icon
  /// @returns a widget that displays the icon for animal welfare Beef
  const MealBeefAwIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.secondary, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(_width))),
        child: SvgPicture.asset('assets/icons/beef.svg'));
  }
}