import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the logo icon
class LogoIcon extends StatelessWidget {
  final double? _size;

  /// This widget is used to display the logo icon
  const LogoIcon({super.key, double size = 24}) : _size = size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo.svg',
      width: _size,
      height: _size,
    );
  }
}
