import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/exceptions/ErrorExceptionIcon.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the exception for no connection to the server.
class MealPlanError extends StatelessWidget {
  /// Creates a no connection widget.
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
                    const SizedBox(height: 16),
                    Text(
                      FlutterI18n.translate(
                          context, "mealplanException.noConnectionException"),
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    MensaButton(
                        onPressed: () async {
                          // Mach das einfach als lokale Variable
                          final temporalMessage =
                              await mealAccess.refreshMealplan() ?? "";
                          if (!context.mounted) return;
                          if (temporalMessage.isNotEmpty) {
                            final snackBar = SnackBar(
                              content: Text(FlutterI18n.translate(
                                  context, temporalMessage)),
                              backgroundColor:
                                  Theme.of(context).colorScheme.onError,
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        text: FlutterI18n.translate(
                            context, "mealplanException.noConnectionButton")),
                  ]),
            ));
  }
}
