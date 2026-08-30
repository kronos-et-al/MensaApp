import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This widget is used to display the icon for a meal.
class MealIcon extends StatelessWidget {
  final FoodType _foodType;
  final double _width;
  final double _height;

  /// This widget is used to display the icon for a meal.
  const MealIcon({
    Key? key,
    required FoodType foodType,
    double width = 24,
    double height = 24,
  }) : _foodType = foodType,
       _width = width,
       _height = height,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    bool hasBorder = false;

    switch (_foodType) {
      case FoodType.beef:
        assetPath = 'assets/icons/beef.svg';
        break;
      case FoodType.beefAw:
        assetPath = 'assets/icons/beef.svg';
        hasBorder = true;
        break;
      case FoodType.pork:
        assetPath = 'assets/icons/pork.svg';
        break;
      case FoodType.porkAw:
        assetPath = 'assets/icons/pork.svg';
        hasBorder = true;
        break;
      case FoodType.fish:
        assetPath = 'assets/icons/fish.svg';
        break;
      case FoodType.vegetarian:
        assetPath = 'assets/icons/vegetarian.svg';
        break;
      case FoodType.vegan:
        assetPath = 'assets/icons/vegan.svg';
        break;
      case FoodType.poultry:
        assetPath = 'assets/icons/poultry.svg';
        break;
      default:
        return SizedBox(width: _width, height: _height);
    }

    if (hasBorder) {
      return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(_width)),
        ),
        child: SvgPicture.asset(assetPath),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(
          assetPath,
          width: _width - 4,
          height: _height - 4,
        ),
      );
    }
  }
}
