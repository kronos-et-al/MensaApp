import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

/// This class is used to display the allergens and additives of a meal.
class MealAccordionInfo extends StatelessWidget {
  final List<Allergen> _allergens;
  final List<Additive> _additives;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final int? _frequency;

  final DateFormat _dateFormat = DateFormat.yMd("de_DE");

  /// Creates a MealAccordionInfo widget.
  MealAccordionInfo({super.key,
    required List<Allergen> allergens,
    required List<Additive> additives,
    DateTime? lastServed,
    DateTime? nextServed,
    int? frequency})
      : _allergens = allergens,
        _additives = additives,
        _lastServed = lastServed,
        _nextServed = nextServed,
        _frequency = frequency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          FlutterI18n.translate(
              context,
              _allergens.isEmpty
                  ? "allergen.allergenTitleEmpty"
                  : "allergen.allergenTitle"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._allergens.map((e) =>
            Row(
              children: [
                const Text("• "),
                Expanded(child: I18nText("allergen.${e.name}")),
              ],
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
        ..._additives.map((e) =>
            Row(
              children: [
                const Text("• "),
                Expanded(child: I18nText("additive.${e.name}")),
              ],
            )),
      ],
    );
  }
}
