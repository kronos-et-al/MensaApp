import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/exceptions/ErrorExceptionIcon.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class MealPlanError extends StatelessWidget {
  const MealPlanError({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IMealAccess>(
        builder: (context, mealAccess, child) => Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ErrorExceptionIcon(size: 48),
                    Text(
                      FlutterI18n.translate(
                          context, "mealplanException.noConnectionException"),
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    MensaButton(
                        onPressed: () async {
                          // Mach das einfach als lokale Variable
                          final temporalMessage =
                              await mealAccess.refreshMealplan() ?? "";
                          if (temporalMessage.isNotEmpty) {
                            final snackBar = SnackBar(
                              content: Text(FlutterI18n.translate(
                                  context, temporalMessage)),
                              backgroundColor: Theme.of(context).colorScheme.onError,
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        text: FlutterI18n.translate(context, "mealplanException.noConnectionButton")),
                  ]),
            ));
  }
}
