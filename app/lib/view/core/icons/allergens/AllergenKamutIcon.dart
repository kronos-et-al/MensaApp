import 'package:flutter/material.dart';

import 'AllergenIcon.dart';

class AllergenKamutIcon extends AllergenIcon {
  const AllergenKamutIcon(
      {super.key, super.width, super.height, super.color});

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
