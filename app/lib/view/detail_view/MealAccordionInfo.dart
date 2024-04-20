import 'package:app/view/detail_view/MealEnvironmentInfo.dart';
import 'package:app/view/detail_view/MealNutrientsList.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/EnvironmentInfo.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

/// This class is used to display the allergens and additives of a meal.
class MealAccordionInfo extends StatelessWidget {
  final List<Allergen> _allergens;
  final List<Additive> _additives;
  final NutritionData? _nutritionData;
  final EnvironmentInfo? _environmentInfo;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final int? _frequency;

  /// Creates a MealAccordionInfo widget.
  MealAccordionInfo(
      {super.key,
      required List<Allergen> allergens,
      required List<Additive> additives,
      NutritionData? nutritionData,
      EnvironmentInfo? environmentInfo,
      DateTime? lastServed,
      DateTime? nextServed,
      int? frequency})
      : _allergens = allergens,
        _additives = additives,
        _nutritionData = nutritionData,
        _environmentInfo = environmentInfo,
        _lastServed = lastServed,
        _nextServed = nextServed,
        _frequency = frequency;

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat("E dd.MM.yyyy",
        FlutterI18n.currentLocale(context)?.languageCode ?? "de-DE");
    ThemeData theme = Theme.of(context);
    print(_environmentInfo);
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
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface
                              : theme.colorScheme.background,
                          width: 2)),
                  child: MealNutrientsList(
                      nutritionData: _nutritionData!, additives: _additives))),
        Padding(
            padding: const EdgeInsets.only(right: 8, left: 6, top: 2),
            child: Text(
              "${FlutterI18n.translate(context, _allergens.isNotEmpty ? "allergen.allergenTitle" : "allergen.allergenTitleEmpty")} ${_allergens.map((e) => FlutterI18n.translate(context, "allergen.${e.name}")).join(", ")}",
              style: const TextStyle(
                fontWeight: FontWeight.w300,
              ),
            )),
        const SizedBox(height: 8),
        _environmentInfo != null
            ? MealEnvironmentInfo(environmentInfo: _environmentInfo!)
            : const SizedBox(height: 0),
        (_frequency != null && _lastServed != null && _nextServed != null)
            ? Text(
                FlutterI18n.translate(context, "mealDetails.frequency",
                    translationParams: {
                      "frequency": _frequency.toString(),
                      "lastServed": _dateFormat.format(_lastServed!),
                      "nextServed": _dateFormat.format(_nextServed!)
                    }),
                style:
                    const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
              )
            : const SizedBox(height: 0),
        (_lastServed != null || _nextServed != null || _frequency != null)
            ? const SizedBox(
                height: 4,
              )
            : const SizedBox(
                height: 0,
              ),
      ],
    );
  }
}
