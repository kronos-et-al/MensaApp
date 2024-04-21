import 'package:app/view/detail_view/MealNutrientsList.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

/// This class is used to display the allergens and additives of a meal.
class MealAccordionInfo extends StatelessWidget {
  final List<Allergen> _allergens;
  final List<Additive> _additives;
  final NutritionData? _nutritionData;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final int? _frequency;

  final DateFormat _dateFormat = DateFormat.yMd("de_DE");

  /// Creates a MealAccordionInfo widget.
  MealAccordionInfo(
      {super.key,
      required List<Allergen> allergens,
      required List<Additive> additives,
      NutritionData? nutritionData,
      DateTime? lastServed,
      DateTime? nextServed,
      int? frequency})
      : _allergens = allergens,
        _additives = additives,
        _nutritionData = nutritionData,
        _lastServed = lastServed,
        _nextServed = nextServed,
        _frequency = frequency;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (_nutritionData != null)
          Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Ink(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: theme.brightness == Brightness.dark ?  theme.colorScheme.surface : theme.colorScheme.background, width: 2)),
                  child: MealNutrientsList(nutritionData: _nutritionData!))),
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              "${FlutterI18n.translate(context, _allergens.isNotEmpty ? "allergen.allergenTitle" : "allergen.allergenTitleEmpty")} ${_allergens.map((e) => FlutterI18n.translate(context, "allergen.${e.name}")).join(", ")}",
            )),
        const SizedBox(height: 8),
        Text(
          FlutterI18n.translate(
              context,
              _additives.isEmpty
                  ? "additive.additiveTitleEmpty"
                  : "additive.additiveTitle"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._additives.map((e) => Row(
              children: [
                const Text("• "),
                Expanded(child: I18nText("additive.${e.name}")),
              ],
            )),
        (_lastServed != null || _nextServed != null || _frequency != null)
            ? const SizedBox(
                height: 8,
              )
            : const SizedBox(
                height: 0,
              ),
        _lastServed != null
            ? Text(FlutterI18n.translate(context, "mealDetails.lastServed",
                translationParams: {
                    "lastServed": _dateFormat.format(_lastServed!)
                  }))
            : const SizedBox(height: 0),
        _nextServed != null
            ? Text(FlutterI18n.translate(context, "mealDetails.nextServed",
                translationParams: {
                    "nextServed": _dateFormat.format(_nextServed!)
                  }))
            : const SizedBox(height: 0),
        _frequency != null
            ? Text(FlutterI18n.translate(context, "mealDetails.frequency",
                translationParams: {"frequency": _frequency.toString()}))
            : const SizedBox(height: 0),
      ],
    );
  }
}
