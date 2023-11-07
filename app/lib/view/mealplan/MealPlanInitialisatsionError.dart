import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/exceptions/ErrorExceptionIcon.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the exception for no connection to the server.
class MealPlanInitialisationError extends StatefulWidget {
  /// Creates a no connection widget.
  const MealPlanInitialisationError({super.key});

  @override
  State<MealPlanInitialisationError> createState() =>
      _MealPlanInitialisationErrorState();
}

class _MealPlanInitialisationErrorState
    extends State<MealPlanInitialisationError> {
  bool loading = false;

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
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(
                      FlutterI18n.translate(
                          context, "mealplanException.initialisationException"),
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(height: 16),
                    MensaButton(
                        loading: loading,
                        disabled: loading,
                        semanticLabel: FlutterI18n.translate(
                            context, "semantics.mealPlanRefresh"),
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          await mealAccess.reInit();
                          setState(() {
                            loading = false;
                          });
                        },
                        text: FlutterI18n.translate(
                            context, "mealplanException.noConnectionButton")),
                  ]),
            ));
  }
}
