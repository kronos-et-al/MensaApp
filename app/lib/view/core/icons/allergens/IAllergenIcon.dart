import 'package:flutter/material.dart';

/// Abstract class for all allergen icons.
abstract class IAllergenIcon extends StatelessWidget {
  final double _width;
  final double _height;
  final Color _color;

  /// Creates an allergen icon.
  const IAllergenIcon(
      {super.key,
      double width = 24,
      double height = 24,
      Color color = Colors.black})
      : _width = width,
        _height = height,
        _color = color;

  /// Returns the color of the icon.
  Color get color => _color;

  /// Returns the height of the icon.
  double get height => _height;

  /// Returns the width of the icon.
  double get width => _width;
}
