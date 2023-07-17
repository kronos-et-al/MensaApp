import 'package:flutter/material.dart';
import 'AllergenIcon.dart';

/// This widget is used to display the icon for Gelatine
class AllergenGelatineIcon extends AllergenIcon {
  const AllergenGelatineIcon(
      {super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('GE',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}