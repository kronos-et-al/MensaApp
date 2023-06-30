import 'package:flutter/material.dart';

import 'AllergenIcon.dart';

class AllergenCashewsIcon extends AllergenIcon {
  const AllergenCashewsIcon(
      {super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return Text('CA',
        style: TextStyle(
            height: 1.5,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color));
  }
}
