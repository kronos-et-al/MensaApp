import 'package:app/view/core/Tag.dart';
import 'package:app/view/core/icons/MealIcon.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays a Main Dish.
class MealMainEntry extends StatelessWidget {
  final Meal _meal;

  // TODO use locale
  final NumberFormat _priceFormat =
      NumberFormat.currency(locale: 'de_DE', symbol: '€');

  /// Creates a MealMainEntry.
  MealMainEntry({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<IPreferenceAccess>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MealIcon(foodType: _meal.foodType, width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(text: TextSpan(text: _meal.name + " ",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                children: getTags(context, _meal))),
          ),
          const SizedBox(width: 8),
          Text(
              _priceFormat.format(
                  _meal.price.getPrice(preferences.getPriceCategory()) / 100),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ))
        ],
      ),
    );
  }
}
