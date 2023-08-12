import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

/// Displays a overview over the ratings for a meal.
class RatingsOverview extends StatelessWidget {
  final Meal _meal;
  final NumberFormat _numberFormat = NumberFormat("#0.0#", "de_DE");
  final Color? _backgroundColor;

  /// Creates a new RatingsOverview.
  /// @param key The key to identify this widget.
  /// @param meal The meal to display the ratings for.
  /// @return A new RatingsOverview.
  RatingsOverview({super.key, required Meal meal, Color? backgroundColor})
      : _meal = meal,
        _backgroundColor = backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(FlutterI18n.translate(context, "ratings.titleRatings"),
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(_numberFormat.format(_meal.averageRating),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                )),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              MensaRatingInput(
                value: _meal.averageRating ?? 0,
                onChanged: (p0) => {},
                disabled: true,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
                max: 5,
              )
            ]),
            const SizedBox(height: 8),
            Text(
                '${_meal.numberOfRatings.toString()} ${FlutterI18n.translate(context, "ratings.labelRatingsCount")}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                )),
          ],
        ),
      )
    ]);
  }
}
