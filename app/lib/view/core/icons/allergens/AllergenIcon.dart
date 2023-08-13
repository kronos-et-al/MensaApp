import 'package:app/view/core/icons/allergens/AllergenAlmondsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenBarleyIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenBrazilNutsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenCashewsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenCeleryIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenCrustaceansIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenEggsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenFishIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenGelatineIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenHazelnutsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenKamutIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenLoafIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenLupinIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenMacadamiaIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenMilkIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenMolluscsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenMustardIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenOatsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenPeanutsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenPecansIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenPistachiosIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenRyeIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenSesameIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenSoyaIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenSpeltIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenSulphiteIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenWalnutsIcon.dart';
import 'package:app/view/core/icons/allergens/AllergenWheatIcon.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:flutter/material.dart';

import 'IAllergenIcon.dart';

/// This widget is used to display the icon for a given allergen.
class AllergenIcon extends IAllergenIcon {
  final Allergen _allergen;
  final Color? _color;

  /// Creates an new allergen icon.
  const AllergenIcon(
      {super.key,
      required Allergen allergen,
      super.width,
      super.height,
      Color? color})
      : _allergen = allergen,
        _color = color;

  @override
  Widget build(BuildContext context) {
    switch (_allergen) {
      case Allergen.ca:
        return AllergenCashewsIcon(
          width: width,
          height: height,
          color: _color ?? Theme.of(context).colorScheme.onSurface,
        );
      case Allergen.di:
        return AllergenSpeltIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ei:
        return AllergenEggsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.er:
        return AllergenPeanutsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.fi:
        return AllergenFishIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ge:
        return AllergenBarleyIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ha:
        return AllergenHazelnutsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.hf:
        return AllergenOatsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ka:
        return AllergenKamutIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.kr:
        return AllergenCrustaceansIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.lu:
        return AllergenLupinIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ma:
        return AllergenAlmondsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ml:
        return AllergenMilkIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.pa:
        return AllergenBrazilNutsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.pe:
        return AllergenPecansIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.pi:
        return AllergenPistachiosIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.qu:
        return AllergenMacadamiaIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.ro:
        return AllergenRyeIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.sa:
        return AllergenSesameIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.se:
        return AllergenCeleryIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.sf:
        return AllergenSulphiteIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.sn:
        return AllergenMustardIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.so:
        return AllergenSoyaIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.wa:
        return AllergenWalnutsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.we:
        return AllergenWheatIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.wt:
        return AllergenMolluscsIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.la:
        return AllergenLoafIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      case Allergen.gl:
        return AllergenGelatineIcon(
            width: width,
            height: height,
            color: _color ?? Theme.of(context).colorScheme.onSurface);
      default:
        return SizedBox(width: width, height: height);
    }
  }
}
