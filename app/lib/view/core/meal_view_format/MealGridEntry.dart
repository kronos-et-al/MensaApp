import 'package:app/view/core/information_display/MealMainEntry.dart';
import 'package:app/view/core/information_display/MealPreviewImage.dart';
import 'package:app/view/core/information_display/MealSideEntry.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';

/// Displays a Meal as a Gallery Entry.
class MealGridEntry extends StatelessWidget {
  final Meal _meal;
  final double _width;

  /// Creates a MealGridEntry.
  /// @param meal The Meal to display.
  /// @param width The width of the entry.
  /// @param key The key to use for this widget.
  /// @return A MealGridEntry.
  const MealGridEntry({super.key, required Meal meal, required double width})
      : _meal = meal,
        _width = width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: _width,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: GestureDetector(
                onTap: () => {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        content: Text(
                          'MealGridEntry: ${_meal.name}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ))
                    },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                        color: _meal.isFavorite
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surface,
                        width: _meal.isFavorite ? 2 : 0),
                  ),
                  child: Column(children: [
                    MealPreviewImage(
                        meal: _meal,
                        height: 180,
                        displayFavorite: true,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8))),
                    SizedBox(height: 4),
                    MealMainEntry(meal: _meal),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(children: [
                          SizedBox(width: 32),
                          MensaRatingInput(
                            disabled: true,
                            onChanged: (v) {},
                            value: _meal.averageRating ?? 0,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ])),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: _meal.sides
                                  ?.map((e) => MealSideEntry(side: e))
                                  .toList() ??
                              [],
                        )),
                  ]),
                ))));
  }
}
