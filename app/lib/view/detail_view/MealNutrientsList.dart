import 'package:app/view/detail_view/MealNutrientsItem.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This class is used to display the nutrients of a meal.
class MealNutrientsList extends StatelessWidget {
  final NutritionData _nutritionData;

  /// Creates a MealNutrientsList widget.
  MealNutrientsList({super.key, required NutritionData nutritionData})
      : _nutritionData = nutritionData;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: Container(decoration: BoxDecoration(color: theme.colorScheme.surface), child: Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Text(FlutterI18n.translate(context, "nutritionData.nutritionTitle"), style: TextStyle(fontWeight: FontWeight.w500),),),))]),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.energy"), value: _nutritionData.energy, unit: FlutterI18n.translate(context, "nutritionData.energyUnit"),),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.protein"), value: _nutritionData.protein, unit: FlutterI18n.translate(context, "nutritionData.proteinUnit"),),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.carbohydrates"), value: _nutritionData.carbohydrates, even: true, unit: FlutterI18n.translate(context, "nutritionData.carbohydratesUnit"),),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.sugar"), value: _nutritionData.sugar, even: true, indent: true, unit: FlutterI18n.translate(context, "nutritionData.sugarUnit"),),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.fat"), value: _nutritionData.fat, unit: FlutterI18n.translate(context, "nutritionData.fatUnit"),),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.saturatedFat"), value: _nutritionData.saturatedFat, indent: true, unit: FlutterI18n.translate(context, "nutritionData.saturatedFatUnit")),
        MealNutrientsItem(name: FlutterI18n.translate(context, "nutritionData.salt"), value: _nutritionData.salt, even: true, unit: FlutterI18n.translate(context, "nutritionData.saltUnit"),),
      ],
    );
  }
}
