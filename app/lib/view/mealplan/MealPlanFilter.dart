import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/exceptions/ErrorExceptionIcon.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display that no meal reaches the filter preferences.
class MealPlanFilter extends StatelessWidget {
  /// Creates a no filtered meal widget.
  const MealPlanFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IMealAccess>(
        builder: (context, mealAccess, child) => Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const ErrorExceptionIcon(size: 48),
                  const SizedBox(height: 16),
                  Text(
                    FlutterI18n.translate(
                        context, "mealplanException.filterException"),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  MensaButton(
                    semanticLabel: FlutterI18n.translate(context, "semantics.filterDeactivate"),
                      onPressed: () => mealAccess.deactivateFilter(),
                      text: FlutterI18n.translate(
                          context, "mealplanException.filterButton")),
                ])));
  }
}
