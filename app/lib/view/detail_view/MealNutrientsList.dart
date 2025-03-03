import 'package:app/view/detail_view/MealNutrientsItem.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This class is used to display the nutrients of a meal.
class MealNutrientsList extends StatelessWidget {
  final NutritionData _nutritionData;
  final List<Additive> _additives;

  /// Creates a MealNutrientsList widget.
  const MealNutrientsList(
      {super.key,
      required NutritionData nutritionData,
      required List<Additive> additives})
      : _nutritionData = nutritionData,
        _additives = additives;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Ink(
            decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceDim
                    : theme.colorScheme.surface),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                FlutterI18n.translate(context, "nutritionData.nutritionTitle"),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ))
        ]),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.energy"),
          value: _nutritionData.energy,
          unit: FlutterI18n.translate(context, "nutritionData.energyUnit"),
        ),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.protein"),
          value: _nutritionData.protein,
          even: true,
          unit: FlutterI18n.translate(context, "nutritionData.proteinUnit"),
        ),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.carbohydrates"),
          value: _nutritionData.carbohydrates,
          unit:
              FlutterI18n.translate(context, "nutritionData.carbohydratesUnit"),
        ),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.sugar"),
          value: _nutritionData.sugar,
          indent: true,
          unit: FlutterI18n.translate(context, "nutritionData.sugarUnit"),
        ),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.fat"),
          value: _nutritionData.fat,
          even: true,
          unit: FlutterI18n.translate(context, "nutritionData.fatUnit"),
        ),
        MealNutrientsItem(
            name: FlutterI18n.translate(context, "nutritionData.saturatedFat"),
            value: _nutritionData.saturatedFat,
            even: true,
            indent: true,
            unit: FlutterI18n.translate(
                context, "nutritionData.saturatedFatUnit")),
        MealNutrientsItem(
          name: FlutterI18n.translate(context, "nutritionData.salt"),
          value: _nutritionData.salt,
          unit: FlutterI18n.translate(context, "nutritionData.saltUnit"),
        ),
        _additives.isNotEmpty
            ? Row(children: [
                Expanded(
                    child: Ink(
                  decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surfaceDim
                          : theme.colorScheme.surface),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      FlutterI18n.translate(context, "additive.additiveTitle"),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ))
              ])
            : const SizedBox(),
        _additives.isNotEmpty
            ? Row(children: [
                Expanded(
                    child: Ink(
                  decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surfaceDim
                          : theme.colorScheme.surface),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      _additives
                          .map((e) => FlutterI18n.translate(
                              context, "additive.${e.name}"))
                          .join(", "),
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                ))
              ])
            : const SizedBox(),
      ],
    );
  }
}
