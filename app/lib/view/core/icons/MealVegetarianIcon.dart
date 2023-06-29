import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MealVegetarianIcon extends StatelessWidget {
  final double _width;
  final double _height;

  const MealVegetarianIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/icons/vegetarian.svg',
        width: _width, height: _height);
  }
}
