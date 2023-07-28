import 'package:app/view/core/icons/exceptions/NoDataExceptionIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This widget is used to display the exception for no available data on the server.
class MealPlanNoData extends StatelessWidget {
  /// Creates a no data widget
  /// @return a widget that displays the exeption for no available data on the server
  const MealPlanNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          const NoDataExceptionIcon(size: 48),
          const SizedBox(height: 16),
          Text(
            FlutterI18n.translate(context, "mealplanException.noDataException"),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ]));
  }
}
