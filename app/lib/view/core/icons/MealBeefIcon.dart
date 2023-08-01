import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for beef
class MealBeefIcon extends StatelessWidget {
  final double _width;
  final double _height;

  /// This widget is used to display the icon for beef.
  const MealBeefIcon({super.key, double width = 24, double height = 24})
      : _width = width,
        _height = height;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset('assets/icons/beef.svg',
            width: _width - 4, height: _height - 4));
  }
}
