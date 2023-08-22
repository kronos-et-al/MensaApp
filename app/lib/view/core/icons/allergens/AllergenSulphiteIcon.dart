import 'package:flutter/material.dart';
import 'IAllergenIcon.dart';

/// This widget is used to display the icon for sulphite
class AllergenSulphiteIcon extends IAllergenIcon {
  /// Creates an new sulphite icon.
  const AllergenSulphiteIcon(
      {super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('SF',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
