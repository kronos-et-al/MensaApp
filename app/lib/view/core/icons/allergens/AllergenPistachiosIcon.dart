import 'package:flutter/material.dart';

import 'AllergenIcon.dart';

class AllergenPistachiosIcon extends AllergenIcon {
  const AllergenPistachiosIcon(
      {super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('PI',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
