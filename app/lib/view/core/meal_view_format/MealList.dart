import 'package:app/view/core/meal_view_format/MealListLine.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:flutter/material.dart';

/// Displays a List of MealPlans in a List View grouped by their line.
class MealList extends StatelessWidget {
  final List<MealPlan> _mealPlans;

  /// Creates a MealList.
  const MealList({super.key, required List<MealPlan> mealPlans})
      : _mealPlans = mealPlans;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (ctx, index) {
        return MealListLine(mealPlan: _mealPlans[index]);
      },
      itemCount: _mealPlans.length,
    );
  }
}
