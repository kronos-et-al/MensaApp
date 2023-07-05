import 'package:app/view/core/icons/MealIcon.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Displays a Side Dish.
class MealSideEntry extends StatelessWidget {
  final Side _side;
  final NumberFormat _priceFormat =
      NumberFormat.currency(locale: 'de_DE', symbol: '€');

  /// Creates a MealSideEntry.
  /// @param side The Side to display.
  /// @param key The key to use for this widget.
  /// @return A MealSideEntry.
  MealSideEntry({Key? key, required Side side})
      : _side = side,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MealIcon(foodType: _side.foodType, width: 24, height: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text('+ ${_side.name}',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14, height: 1.5)),
          ),
          const SizedBox(width: 8),
          // TODO use correct price
          Text(
              _priceFormat
                  .format(_side.price.getPrice(PriceCategory.student) / 100),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}
