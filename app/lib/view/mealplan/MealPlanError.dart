import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

// todo text style
class MealPlanError extends StatelessWidget {
  String _temporalMessage = "";

  MealPlanError({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IMealAccess>(
        builder: (context, mealAccess, child) => Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // todo add icon
                  Text(FlutterI18n.translate(
                      context, "mealplanException.noConnectionException")),
                  MensaButton(
                      onPressed: () async {
                        // Mach das einfach als lokale Variable
                        _temporalMessage =
                            await mealAccess.refreshMealplan() ?? "";
                        if (_temporalMessage.isNotEmpty) {
                          final snackBar = SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, _temporalMessage)),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      text: "mealplanException.noConnectionButton"),
                ])));
  }
}
