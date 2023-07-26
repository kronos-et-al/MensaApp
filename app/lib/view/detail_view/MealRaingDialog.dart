import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class MealRatingDialog {
  static void show(BuildContext context, String mealTitle, Meal meal) {
    int rating = meal.individualRating ?? 0;
    
    MensaDialog.show(context: context,
      title: "$mealTitle ${FlutterI18n.translate(context, "ratings.dialogTitle")}",
      content: Consumer<IMealAccess>(builder: (context, mealAccess, child) =>
      Column(children: [
        MensaRatingInput(onChanged: (value) {
          rating = value;
        },
            value: rating as double),
        Row(children: [
          const Spacer(),
          MensaButton(onPressed: () async {
            final temporalMessage = await mealAccess.updateMealRating(rating, meal);
            Navigator.pop(context);

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
              text: FlutterI18n.translate(context, "image.saveRating"))
        ],)
      ],))
    );
  }
}