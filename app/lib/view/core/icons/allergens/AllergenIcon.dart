import 'package:flutter/material.dart';

/// Abstract class for all allergen icons.
abstract class AllergenIcon extends StatelessWidget {
  final double _width;
  final double _height;
  final Color _color;

  /// Creates an allergen icon.
  /// @param key The key to use for this widget.
  /// @param width The width of the icon.
  /// @param height The height of the icon.
  /// @param color The color of the icon.
  const AllergenIcon({super.key, double width = 24, double height = 24, Color color = Colors.black}): _width = width, _height = height, _color = color;

  /// Returns the color of the icon.
  Color get color => _color;

  /// Returns the height of the icon.
  double get height => _height;

  /// Returns the width of the icon.
  double get width => _width;
}