import 'package:app/view/core/icons/MealIcon.dart';
import 'package:app/view/core/information_display/MealPreviewImage.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view/detail_view/DetailsPage.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Displays a Meal as a List Entry.
class MealListEntry extends StatelessWidget {
  final Meal _meal;
  final Line? _line;

  // TODO use locale
  final NumberFormat _priceFormat =
      NumberFormat.currency(locale: 'de_DE', symbol: '€');

  /// Creates a MealListEntry.
  /// @param meal The Meal to display.
  /// @param key The key to use for this widget.
  /// @return A MealListEntry.flutter
  MealListEntry({super.key, required Meal meal, Line? line})
      : _meal = meal,
        _line = line;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: GestureDetector(
            onTap: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DetailsPage(
                      meal: _meal,
                      line: _line,
                    ),
                  ))
                },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    MealPreviewImage(
                        meal: _meal,
                        height: 86,
                        width: 86,
                        onImagePressed: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsPage(meal: _meal, line: _line,)))
                        },
                        displayFavorite: true,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8))),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(
                                    _meal.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5),
                                  ))
                                ]),
                                const Spacer(),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(children: [
                                  MealIcon(
                                      foodType: _meal.foodType,
                                      width: 24,
                                      height: 24),
                                  const SizedBox(width: 4),
                                  MensaRatingInput(
                                    size: 20,
                                    onChanged: (v) => {},
                                    value: _meal.averageRating ?? 0,
                                    disabled: true,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  const Spacer(),
                                  Text(_priceFormat.format(_meal.price
                                          .getPrice(PriceCategory.student) /
                                      100)),
                                ]),
                              ],
                            )))
                  ])),
            )));
  }
}
