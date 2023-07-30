import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This class is used to display the allergens and additives of a meal.
class MealAccordionInfo extends StatelessWidget {
  final List<Allergen> _allergens;
  final List<Additive> _additives;

  /// Creates a MealAccordionInfo widget.
  /// @param key The key to identify this widget.
  /// @param allergens The allergens of the meal.
  /// @param additives The additives of the meal.
  /// @returns A new MealAccordionInfo widget.
  const MealAccordionInfo(
      {super.key,
      required List<Allergen> allergens,
      required List<Additive> additives})
      : _allergens = allergens,
        _additives = additives;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          "Allergene:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._allergens.map((e) => Row(
              children: [
                const Text("• "),
                Expanded(child: I18nText("allergen.${e.name}")),
              ],
            )),
        const SizedBox(height: 8),
        const Text(
          "Zusatzstoffe:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._additives.map((e) => Row(
              children: [
                const Text("• "),
                Expanded(child: I18nText("additive.${e.name}")),
              ],
            )),
      ],
    );
  }
}
