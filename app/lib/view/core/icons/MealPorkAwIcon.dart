import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MealPorkAwIcon extends StatelessWidget {
  final double _width;
  final double _height;

  const MealPorkAwIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(_width))),
        child: SvgPicture.asset('assets/icons/pork.svg',
            width: _width, height: _height));
  }
}
