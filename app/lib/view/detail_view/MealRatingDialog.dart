import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display a dialog to rate a meal.
class MealRatingDialog extends StatefulWidget {
  final Meal _meal;
  final Function(Meal)? _onRatingChanged;

  /// Creates a new MealRatingDialog.
  const MealRatingDialog(
      {super.key, required Meal meal, Function(Meal)? onRatingChanged})
      : _meal = meal,
        _onRatingChanged = onRatingChanged;

  @override
  State<MealRatingDialog> createState() => _MealRatingDialogState();
}

class _MealRatingDialogState extends State<MealRatingDialog> {
  int? rating;

  @override
  Widget build(BuildContext context) {
    Meal meal = widget._meal;
    rating = rating ?? meal.individualRating ?? 0;
    return MensaDialog(
        title:
            "${meal.name} ${FlutterI18n.translate(context, "ratings.dialogTitle")}",
        content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MensaRatingInput(
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                    value: rating!.toDouble()),
              ],
            )),
        actions: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                MensaButton(
                    semanticLabel: FlutterI18n.translate(
                        context, "semantics.mealRatingSubmit"),
                    onPressed: () async {
                      final result =
                          await context.read<IMealAccess>().updateMealRating(
                                rating!,
                                meal,
                              );
                      if (!context.mounted) return;

                      if (result) {
                        final snackBar = SnackBar(
                            content: Text(
                              FlutterI18n.translate(
                                  context, "snackbar.updateRatingSuccess"),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary);

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        final snackBar = SnackBar(
                            content: Text(
                              FlutterI18n.translate(
                                  context, "snackbar.updateRatingError"),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.error);

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      Navigator.pop(context);
                    },
                    text: FlutterI18n.translate(context, "ratings.saveRating"))
              ],
            )));
  }
}
