import 'package:app/view/core/icons/MealIcon.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealMainEntry extends StatelessWidget {
  final Meal _meal;
  final NumberFormat _priceFormat =
      NumberFormat.currency(locale: 'de_DE', symbol: '€');

  MealMainEntry({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MealIcon(foodType: _meal.foodType, width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_meal.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.5)),
          ),
          const SizedBox(width: 8),
          // TODO use correct price
          Text(_priceFormat
              .format(_meal.price.getPrice(PriceCategory.student) / 100), style: const TextStyle(fontSize: 14, height: 1.5, )),
        ],
      ),
    );
  }
}
