import 'package:flutter/material.dart';
import 'IAllergenIcon.dart';

/// This widget is used to display the icon for Spelt
class AllergenSpeltIcon extends IAllergenIcon {
  const AllergenSpeltIcon({super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('DI',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
