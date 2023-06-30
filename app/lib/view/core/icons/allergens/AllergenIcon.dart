import 'package:flutter/material.dart';

abstract class AllergenIcon extends StatelessWidget {
  final double _width;
  final double _height;
  final Color _color;
  const AllergenIcon({super.key, double width = 24, double height = 24, Color color = Colors.black}): _width = width, _height = height, _color = color;

  Color get color => _color;

  double get height => _height;

  double get width => _width;
}