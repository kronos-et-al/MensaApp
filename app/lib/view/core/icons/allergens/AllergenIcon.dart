import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'IAllergenIcon.dart';

/// This widget is used to display the icon for a given allergen.
class AllergenIcon extends IAllergenIcon {
  final Allergen _allergen;
  final Color? _color;

  /// Creates an new allergen icon.
  const AllergenIcon({
    super.key,
    required Allergen allergen,
    super.width,
    super.height,
    Color? color,
  }) : _allergen = allergen,
       _color = color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _color ?? Theme.of(context).colorScheme.onSurface;

    switch (_allergen) {
      case Allergen.ca:
        return _buildTextIcon('CA', effectiveColor);
      case Allergen.di:
        return _buildTextIcon('DI', effectiveColor);
      case Allergen.ei:
        return _buildSvgIcon('ei', effectiveColor);
      case Allergen.er:
        return _buildSvgIcon('er', effectiveColor);
      case Allergen.fi:
        return _buildSvgIcon('fi', effectiveColor);
      case Allergen.ge:
        return _buildSvgIcon('ge', effectiveColor);
      case Allergen.ha:
        return _buildSvgIcon('ha', effectiveColor);
      case Allergen.hf:
        return _buildSvgIcon('hf', effectiveColor);
      case Allergen.ka:
        return _buildTextIcon('KA', effectiveColor);
      case Allergen.kr:
        return _buildSvgIcon('kr', effectiveColor);
      case Allergen.lu:
        return _buildTextIcon('LU', effectiveColor);
      case Allergen.ma:
        return _buildSvgIcon('ma', effectiveColor);
      case Allergen.ml:
        return _buildSvgIcon('ml', effectiveColor);
      case Allergen.pa:
        return _buildSvgIcon('pa', effectiveColor);
      case Allergen.pe:
        return _buildSvgIcon('pe', effectiveColor);
      case Allergen.pi:
        return _buildTextIcon('PI', effectiveColor);
      case Allergen.qu:
        return _buildTextIcon('QU', effectiveColor);
      case Allergen.ro:
        return _buildTextIcon('RO', effectiveColor);
      case Allergen.sa:
        return _buildSvgIcon('sa', effectiveColor);
      case Allergen.se:
        return _buildSvgIcon('se', effectiveColor);
      case Allergen.sf:
        return _buildTextIcon('SF', effectiveColor);
      case Allergen.sn:
        return _buildSvgIcon('sn', effectiveColor);
      case Allergen.so:
        return _buildSvgIcon('so', effectiveColor);
      case Allergen.wa:
        return _buildSvgIcon('wa', effectiveColor);
      case Allergen.we:
        return _buildSvgIcon('we', effectiveColor);
      case Allergen.wt:
        return _buildSvgIcon('wt', effectiveColor);
      case Allergen.la:
        return _buildSvgIcon('la', effectiveColor);
      case Allergen.gl:
        return _buildTextIcon('GL', effectiveColor);
    }
  }

  Widget _buildSvgIcon(String name, Color color) {
    return SvgPicture.asset(
      'assets/icons/allergens/$name.svg',
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  Widget _buildTextIcon(String text, Color color) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            height: 1,
            fontSize: height / 1.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
