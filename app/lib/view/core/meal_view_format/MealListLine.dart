import 'package:app/view/core/meal_view_format/MealListEntry.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:flutter/material.dart';

/// Displays the section for the MealList with all meals of a line.
class MealListLine extends StatelessWidget {

  final MealPlan _mealPlan;

  /// Creates a MealListLine.
  /// @param mealPlan The MealPlan to display.
  /// @param key The key to use for this widget.
  /// @return A MealListLine.
  const MealListLine({super.key, required MealPlan mealPlan})
      : _mealPlan = mealPlan;

  @override
  Widget build(BuildContext context) {
    return (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(_mealPlan.line.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 1.5)),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _mealPlan.meals.length,
              itemBuilder: (context, index) {
                return MealListEntry(meal: _mealPlan.meals[index]);
              },
            ),
          ],
        )
    );
  }


}