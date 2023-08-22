import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'IAllergenIcon.dart';

/// This widget is used to display the icon for crustaceans
class AllergenCrustaceansIcon extends IAllergenIcon {
  /// Creates an new crustaceans icon.
  const AllergenCrustaceansIcon(
      {super.key, super.width, super.height, super.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/allergens/kr.svg',
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
