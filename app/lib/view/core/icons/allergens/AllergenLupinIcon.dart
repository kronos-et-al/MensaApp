import 'package:flutter/material.dart';
import 'IAllergenIcon.dart';

/// This widget is used to display the icon for lupin
class AllergenLupinIcon extends IAllergenIcon {
  /// Creates an new lupin icon.
  const AllergenLupinIcon({super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('LU',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
