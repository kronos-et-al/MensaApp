import 'package:flutter/material.dart';
import 'IAllergenIcon.dart';

/// This widget is used to display the icon for kamut
class AllergenKamutIcon extends IAllergenIcon {
  /// Creates an new kamut icon.
  const AllergenKamutIcon({super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('KA',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
