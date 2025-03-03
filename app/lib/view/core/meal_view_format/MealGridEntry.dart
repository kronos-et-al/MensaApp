import 'package:app/view/core/Tag.dart';
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
  final Line _line;
  final DateTime _date;
  final double _width;

  /// Creates a MealGridEntry.
  const MealGridEntry(
      {super.key,
      required Meal meal,
      required Line line,
      required DateTime date,
      required double width})
      : _meal = meal,
        _line = line,
        _date = date,
        _width = width;

  @override
  Widget build(BuildContext context) {
    var borderColor = getBorderColor(context, _meal);
    return SizedBox(
            width: _width,
            child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: borderColor != null ? 5.5 : 8, horizontal: borderColor != null ? 9.5 : 12),
                child: GestureDetector(
                    onTap: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    meal: _meal,
                                    line: _line,
                                    date: _date,
                                  )))
                        },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.surfaceDim,
                        border:  Border.all(
                      color: borderColor ?? Theme
                          .of(context)
                          .colorScheme
                          .surfaceDim,
                        width: borderColor != null ? 2.5 : 0),
                      ),
                      child: Column(children: [
                        MealPreviewImage(
                            meal: _meal,
                            height: 180,
                            displayFavorite: true,
                            enableFavoriteButton: true,
                            onImagePressed: () => {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DetailsPage(
                                            meal: _meal,
                                            line: _line,
                                            date: _date,
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
