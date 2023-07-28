import 'package:app/view/core/icons/exceptions/CanteenClosedExceptionIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This widget is used to display the exception for a closed canteen.
class MealPlanClosed extends StatelessWidget {
  /// Creates a closed canteen widget.
  /// @return a widget that displays the exception for a closed canteen
  const MealPlanClosed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          const CanteenClosedExceptionIcon(size: 48),
          const SizedBox(height: 16),
          Text(
            FlutterI18n.translate(
                context, "mealplanException.closedCanteenException"),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ]));
  }
}
