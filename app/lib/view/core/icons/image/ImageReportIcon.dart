import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for a report of an image
class ImageReportIcon extends StatelessWidget {
  final double? _size;
  final Color? _color;

  /// Creates a new report icon.
  /// @param key The key to identify this widget.
  /// @param size The size of the icon.
  /// @param color The color of the icon.
  /// @return a widget that displays the icon for a report of an image
  const ImageReportIcon({super.key, double size = 24, Color? color})
      : _size = size,
        _color = color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/image/image_report.svg',
      width: _size,
      height: _size,
      colorFilter: ColorFilter.mode(
          _color ?? Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
