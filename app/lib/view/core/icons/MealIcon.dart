import 'package:app/view/core/icons/MealBeefAwIcon.dart';
import 'package:app/view/core/icons/MealBeefIcon.dart';
import 'package:app/view/core/icons/MealFishIcon.dart';
import 'package:app/view/core/icons/MealPorkAwIcon.dart';
import 'package:app/view/core/icons/MealPorkIcon.dart';
import 'package:app/view/core/icons/MealVeganIcon.dart';
import 'package:app/view/core/icons/MealVegetarianIcon.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:flutter/material.dart';

/// This widget is used to display the icon for a meal.
class MealIcon extends StatelessWidget {
  final FoodType _foodType;
  final double _width;
  final double _height;

  /// This widget is used to display the icon for a meal.
  /// @param key is the key for this widget
  /// @param foodType is the type of food the meal is
  /// @param width is the width of the icon
  /// @param height is the height of the icon
  /// @returns a widget that displays the icon for a meal
  const MealIcon(
      {Key? key,
      required FoodType foodType,
      double width = 24,
      double height = 24})
      : _foodType = foodType,
        _width = width,
        _height = height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (_foodType) {
      case FoodType.beef:
        return MealBeefIcon(width: _width, height: _height);
      case FoodType.beefAw:
        return MealBeefAwIcon(width: _width, height: _height);
      case FoodType.pork:
        return MealPorkIcon(width: _width, height: _height);
      case FoodType.porkAw:
        return MealPorkAwIcon(width: _width, height: _height);
      case FoodType.fish:
        return MealFishIcon(width: _width, height: _height);
      case FoodType.vegetarian:
        return MealVegetarianIcon(width: _width, height: _height);
      case FoodType.vegan:
        return MealVeganIcon(width: _width, height: _height);
      default:
        return SizedBox(width: _width, height: _height);
    }
  }
}