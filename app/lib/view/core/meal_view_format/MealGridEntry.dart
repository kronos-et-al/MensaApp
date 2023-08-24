import 'package:app/view/core/information_display/MealMainEntry.dart';
import 'package:app/view/core/information_display/MealPreviewImage.dart';
import 'package:app/view/core/information_display/MealSideEntry.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view/detail_view/DetailsPage.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:flutter/material.dart';

/// Displays a Meal as a Gallery Entry.
class MealGridEntry extends StatelessWidget {
  final Meal _meal;
  final Line? _line;
  final double _width;

  /// Creates a MealGridEntry.
  const MealGridEntry(
      {super.key, required Meal meal, Line? line, required double width})
      : _meal = meal,
        _line = line,
        _width = width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: _width,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: GestureDetector(
                onTap: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailsPage(
                                meal: _meal,
                                line: _line,
                              )))
                    },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                        onImagePressed: () => {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                        meal: _meal,
                                        line: _line,
                                      )))
                            },
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8))),
                    const SizedBox(height: 4),
                    MealMainEntry(meal: _meal),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(children: [
                          const SizedBox(width: 32),
                          MensaRatingInput(
                            disabled: true,
                            onChanged: (v) {},
                            value: _meal.averageRating,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ])),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
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
