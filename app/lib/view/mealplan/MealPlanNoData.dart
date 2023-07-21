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
    return Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NoDataExceptionIcon(size: 48),
          Text(
            FlutterI18n.translate(context, "mealplanException.noDataException"),
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
            textAlign: TextAlign.center,
          ),
        ]);
  }
}
