import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaIconButton.dart';
import 'package:app/view/core/icons/favorites/FavoriteFilledIcon.dart';
import 'package:app/view/core/icons/favorites/FavoriteOutlinedIcon.dart';
import 'package:app/view/core/icons/meal/MealLineIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationAddImageIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationBackIcon.dart';
import 'package:app/view/core/information_display/MealMainEntry.dart';
import 'package:app/view/core/information_display/MealPreviewImage.dart';
import 'package:app/view/core/information_display/MealSideEntry.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view/detail_view/MealAccordion.dart';
import 'package:app/view/detail_view/MealAccordionInfo.dart';
import 'package:app/view/detail_view/MealRatingDialog.dart';
import 'package:app/view/detail_view/RatingsOverview.dart';
import 'package:app/view/detail_view/UploadImageDialog.dart';
import 'package:app/view/images/MealImageDialog.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the details of a meal.
class DetailsPage extends StatefulWidget {
  final Meal _meal;
  final Line? _line;

  /// Creates a new DetailsPage.
  /// @param key The key to identify this widget.
  /// @param meal The meal to display.
  /// @param line The line of the meal.
  /// @returns A new DetailsPage.
  const DetailsPage({super.key, required Meal meal, Line? line})
      : _meal = meal,
        _line = line;

  @override
  State<StatefulWidget> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  int? expandedAccordionIndex;
  Meal? localMeal;

  @override
  Widget build(BuildContext context) {
    Meal meal = localMeal ?? widget._meal;
    ThemeData themeData = Theme.of(context);
    return Container(
        color: themeData.brightness == Brightness.light
            ? themeData.colorScheme.background
            : themeData.colorScheme.background,
        child: SafeArea(
            child: Scaffold(
          appBar: MensaAppBar(
            appBarHeight: kToolbarHeight * 1.25,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MensaIconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const NavigationBackIcon()),
                    const Spacer(),
                    Consumer<IFavoriteMealAccess>(
                        builder: (context, favoriteMealAccess, child) =>
                            MensaIconButton(
                                onPressed: () => {
                                      if (meal.isFavorite)
                                        {
                                          favoriteMealAccess
                                              .removeFavoriteMeal(meal)
                                        }
                                      else
                                        {
                                          favoriteMealAccess
                                              .addFavoriteMeal(meal)
                                        }
                                    },
                                icon: meal.isFavorite
                                    ? const FavoriteFilledIcon()
                                    : const FavoriteOutlinedIcon())),
                    MensaIconButton(
                        onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    UploadImageDialog(meal: meal),
                              )
                            },
                        icon: const NavigationAddImageIcon()),
                  ],
                )),
          ),
          body: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      meal.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ))
                  ])),
              const SizedBox(height: 16),
              Expanded(
                  child: Container(
                      color: themeData.brightness == Brightness.light
                          ? themeData.colorScheme.background
                          : themeData.colorScheme.surface,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget._line != null
                                  ? Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: MealLineIcon(),
                                        ),
                                        Text(
                                          widget._line!.name,
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 8),
                              MealPreviewImage(
                                  enableUploadButton: true,
                                  onUploadButtonPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => UploadImageDialog(
                                            meal: meal),
                                      ),
                                  onImagePressed: () => showDialog(
                                        context: context,
                                        builder: (context) => MealImageDialog(
                                          images: meal.images ?? [],
                                        ),
                                      ),
                                  borderRadius: BorderRadius.circular(4),
                                  meal: meal,
                                  height: 250),
                              const SizedBox(height: 8),
                              MealAccordion(
                                backgroundColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.background
                                        : themeData.colorScheme.surface,
                                expandedColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.surface
                                        : themeData.colorScheme.background,
                                mainEntry: MealMainEntry(meal: meal),
                                info: MealAccordionInfo(
                                    additives: meal.additives ?? [],
                                    allergens: meal.allergens ?? []),
                                isExpanded: expandedAccordionIndex == 0,
                                onTap: () => setState(() =>
                                    expandedAccordionIndex =
                                        expandedAccordionIndex == 0 ? null : 0),
                              ),
                              ...?meal.sides
                                  ?.map((e) => MealAccordion(
                                        backgroundColor: themeData.brightness ==
                                                Brightness.light
                                            ? themeData.colorScheme.background
                                            : themeData.colorScheme.surface,
                                        expandedColor: themeData.brightness ==
                                                Brightness.light
                                            ? themeData.colorScheme.surface
                                            : themeData.colorScheme.background,
                                        sideEntry: MealSideEntry(side: e),
                                        info: MealAccordionInfo(
                                            additives: e.additives,
                                            allergens: e.allergens),
                                        isExpanded: expandedAccordionIndex ==
                                            meal.sides!.indexOf(e) + 1,
                                        onTap: () => setState(() =>
                                            expandedAccordionIndex =
                                                expandedAccordionIndex ==
                                                        meal.sides!
                                                                .indexOf(e) +
                                                            1
                                                    ? null
                                                    : meal.sides!
                                                            .indexOf(e) +
                                                        1),
                                      ))
                                  .toList(),
                              const SizedBox(height: 16),
                              RatingsOverview(
                                meal: meal,
                                backgroundColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.surface
                                        : themeData.colorScheme.background,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                  FlutterI18n.translate(
                                      context, "ratings.titlePersonalRating"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Row(children: [
                                MensaRatingInput(
                                  value: meal.individualRating
                                          ?.toDouble() ??
                                      0,
                                  disabled: true,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                  max: 5,
                                  onChanged: (int) {},
                                ),
                                const Spacer(),
                                MensaButton(
                                  text: FlutterI18n.translate(
                                      context, "ratings.editRating"),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => MealRatingDialog(
                                          onRatingChanged: (meal) {
                                            setState(() {
                                              localMeal = meal;
                                            });
                                          },
                                            meal: meal),
                                        barrierDismissible: true);
                                  },
                                )
                              ])
                            ],
                          ),
                        ),
                      )))
            ],
          ),
        )));
  }
}
