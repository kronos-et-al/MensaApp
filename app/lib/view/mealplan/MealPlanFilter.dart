import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/exceptions/ErrorExceptionIcon.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display that no meal reaches the filter preferences.
class MealPlanFilter extends StatelessWidget {
  /// Creates a no filtered meal widget.
  /// @return a widget that displays the exception that says that no meal reaches the filter preferences
  const MealPlanFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IMealAccess>(
        builder: (context, mealAccess, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ErrorExceptionIcon(size: 48),
              Text(FlutterI18n.translate(
                  context, "mealplanException.filterException"),
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
                textAlign: TextAlign.center,
              ),
              MensaButton(
                  onPressed: () => mealAccess.deactivateFilter(),
                  text: FlutterI18n.translate(context, "mealplanException.filterButton")),
            ]));
  }
  
}