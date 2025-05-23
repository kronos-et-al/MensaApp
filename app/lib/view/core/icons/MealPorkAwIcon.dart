import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for animal welfare pork
class MealPorkAwIcon extends StatelessWidget {
  final double _width;
  final double _height;

  /// This widget is used to display the icon for animal welfare pork.
  const MealPorkAwIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.primary, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(_width))),
        child: SvgPicture.asset('assets/icons/pork.svg'));
  }
}
