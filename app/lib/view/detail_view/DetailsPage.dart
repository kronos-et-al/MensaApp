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
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the details of a meal.
class DetailsPage extends StatefulWidget {
  final Meal _meal;
  final Line _line;
  final DateTime _date;

  /// Creates a new DetailsPage.
  const DetailsPage(
      {super.key,
      required Meal meal,
      required Line line,
      required DateTime date})
      : _meal = meal,
        _line = line,
        _date = date;

  @override
  State<StatefulWidget> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  int? expandedAccordionIndex;
  Meal? localMeal;
  DateFormat dateFormat = DateFormat.yMMMMd("de_DE");

  final DateFormat _dateFormat = DateFormat.yMd("de_DE");

  int? _changedRating;

  @override
  void initState() {
    _changedRating = widget._meal.individualRating;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _changedRating = widget._meal.individualRating;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // These provider are necessary for the synchronization of each other. They need to be initialized even if they are unused.
    IMealAccess mealAccess = Provider.of<IMealAccess>(context);
    Provider.of<IImageAccess>(context);
    ThemeData themeData = Theme.of(context);
    return FutureBuilder(
        future: mealAccess.getMeal(widget._meal),
        builder: (context, mealSnapshot) {
          if (!mealSnapshot.hasData) {
            return Container(
              color: themeData.brightness == Brightness.light
                  ? themeData.colorScheme.background
                  : themeData.colorScheme.background,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (mealSnapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mealSnapshot.error.toString())));
            Navigator.of(context).pop();
            return Container(
              color: themeData.brightness == Brightness.light
                  ? themeData.colorScheme.background
                  : themeData.colorScheme.background,
            );
          }
          switch (mealSnapshot.requireData) {
            case Success<Meal, NoMealException> value:
              {
                Meal meal = value.value;
                return Container(
                    color: themeData.brightness == Brightness.light
                        ? themeData.colorScheme.background
                        : themeData.colorScheme.background,
                    child: SafeArea(
                        child: Scaffold(
                      appBar: MensaAppBar(
                        appBarHeight: kToolbarHeight * 1.25,
                        child: Semantics(
                            header: true,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MensaIconButton(
                                        semanticLabel: FlutterI18n.translate(
                                            context, "semantics.mealClose"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: const NavigationBackIcon()),
                                    const Spacer(),
                                    Consumer<IFavoriteMealAccess>(
                                        builder: (context, favoriteMealAccess,
                                                child) =>
                                            MensaIconButton(
                                                semanticLabel: FlutterI18n.translate(
                                                    context,
                                                    meal.isFavorite
                                                        ? "semantics.mealFavoriteRemove"
                                                        : "semantics.mealFavoriteAdd"),
                                                onPressed: () => {
                                                      if (meal.isFavorite)
                                                        {
                                                          favoriteMealAccess
                                                              .removeFavoriteMeal(
                                                                  meal)
                                                        }
                                                      else
                                                        {
                                                          favoriteMealAccess
                                                              .addFavoriteMeal(
                                                                  meal,
                                                                  widget._date,
                                                                  widget._line)
                                                        }
                                                    },
                                                icon: meal.isFavorite
                                                    ? FavoriteFilledIcon(color: themeData.colorScheme.primary,)
                                                    : const FavoriteOutlinedIcon())),
                                    MensaIconButton(
                                        semanticLabel: FlutterI18n.translate(
                                            context, "semantics.imageUpload"),
                                        onPressed: () => {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    UploadImageDialog(
                                                        meal: meal),
                                              )
                                            },
                                        icon: const NavigationAddImageIcon()),
                                  ],
                                ))),
                      ),
                      body: Column(
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              child: Row(children: [
                                Expanded(
                                    child: Text(
                                  meal.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ))
                              ])),
                          const SizedBox(height: 16),
                          Expanded(
                              child: Container(
                                  color:
                                      themeData.brightness == Brightness.light
                                          ? themeData.colorScheme.background
                                          : themeData.colorScheme.surface,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: MealLineIcon(),
                                              ),
                                              Text(
                                                widget._line.name,
                                                /*"${widget._line.name} | ${dateFormat.format(widget._date)}",*/
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          MealPreviewImage(
                                              enableUploadButton: true,
                                              onUploadButtonPressed: () =>
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        UploadImageDialog(
                                                            meal: meal),
                                                  ),
                                              onImagePressed: () => showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        MealImageDialog(
                                                      meal: meal,
                                                    ),
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              meal: meal,
                                              height: 250),
                                          const SizedBox(height: 8),
                                          MealAccordion(
                                            backgroundColor: themeData
                                                        .brightness ==
                                                    Brightness.light
                                                ? themeData
                                                    .colorScheme.background
                                                : themeData.colorScheme.surface,
                                            expandedColor: themeData
                                                        .brightness ==
                                                    Brightness.light
                                                ? themeData.colorScheme.surface
                                                : themeData
                                                    .colorScheme.background,
                                            mainEntry:
                                                MealMainEntry(meal: meal),
                                            info: MealAccordionInfo(
                                                lastServed: meal.lastServed,
                                                nextServed: meal.nextServed,
                                                frequency:
                                                    meal.numberOfOccurance,
                                                additives: meal.additives ?? [],
                                                allergens: meal.allergens ?? [],
                                                nutritionData: meal.nutritionData,
                                                environmentInfo: meal.environmentInfo),
                                            isExpanded:
                                                expandedAccordionIndex == 0,
                                            onTap: () => setState(() =>
                                                expandedAccordionIndex =
                                                    expandedAccordionIndex == 0
                                                        ? null
                                                        : 0),
                                          ),
                                          ...?meal.sides
                                              ?.map((e) => MealAccordion(
                                                    backgroundColor:
                                                        themeData.brightness ==
                                                                Brightness.light
                                                            ? themeData
                                                                .colorScheme
                                                                .background
                                                            : themeData
                                                                .colorScheme
                                                                .surface,
                                                    expandedColor:
                                                        themeData.brightness ==
                                                                Brightness.light
                                                            ? themeData
                                                                .colorScheme
                                                                .surface
                                                            : themeData
                                                                .colorScheme
                                                                .background,
                                                    sideEntry:
                                                        MealSideEntry(side: e),
                                                    info: MealAccordionInfo(
                                                        additives: e.additives,
                                                        allergens: e.allergens,
                                                        nutritionData: e.nutritionData,
                                                        environmentInfo: e.environmentInfo),
                                                    isExpanded:
                                                        expandedAccordionIndex ==
                                                            meal.sides!.indexOf(
                                                                    e) +
                                                                1,
                                                    onTap: () => setState(() =>
                                                        expandedAccordionIndex =
                                                            expandedAccordionIndex ==
                                                                    meal.sides!.indexOf(
                                                                            e) +
                                                                        1
                                                                ? null
                                                                : meal.sides!
                                                                        .indexOf(
                                                                            e) +
                                                                    1),
                                                  ))
                                              ,
                                          const SizedBox(height: 16),
                                          RatingsOverview(
                                            meal: meal,
                                            backgroundColor: themeData
                                                        .brightness ==
                                                    Brightness.light
                                                ? themeData.colorScheme.surface
                                                : themeData
                                                    .colorScheme.background,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                              FlutterI18n.translate(context,
                                                  "ratings.titlePersonalRating"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Row(children: [
                                            MensaRatingInput(
                                              value:
                                                  _changedRating?.toDouble() ??
                                                      meal.individualRating
                                                          .toDouble(),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              size: 20,
                                              max: 5,
                                              onChanged: (value) async {
                                                setState(() {
                                                  _changedRating = value;
                                                });
                                                await mealAccess
                                                    .updateMealRating(
                                                        value.toInt(), meal);
                                              },
                                            ),
                                            const Spacer(),
                                            MensaButton(
                                              semanticLabel:
                                                  FlutterI18n.translate(context,
                                                      "semantics.mealRatingEdit"),
                                              text: FlutterI18n.translate(
                                                  context,
                                                  "ratings.editRating"),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        MealRatingDialog(
                                                            onRatingChanged:
                                                                (meal) {
                                                              setState(() {
                                                                localMeal =
                                                                    meal;
                                                              });
                                                            },
                                                            meal: meal),
                                                    barrierDismissible: true);
                                              },
                                            )
                                          ]),
                                          const SizedBox(height: 16),
                                          Text(
                                              FlutterI18n.translate(context,
                                                  "mealDetails.titleStatistics"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          (meal.lastServed != null ||
                                                  meal.nextServed != null ||
                                                  meal.numberOfOccurance !=
                                                      null)
                                              ? const SizedBox(
                                                  height: 8,
                                                )
                                              : const SizedBox(
                                                  height: 0,
                                                ),
                                          meal.lastServed != null
                                              ? Text(FlutterI18n.translate(
                                                  context,
                                                  "mealDetails.lastServed",
                                                  translationParams: {
                                                      "lastServed":
                                                          _dateFormat.format(
                                                              meal.lastServed!)
                                                    }))
                                              : const SizedBox(height: 0),
                                          meal.nextServed != null
                                              ? Text(FlutterI18n.translate(
                                                  context,
                                                  "mealDetails.nextServed",
                                                  translationParams: {
                                                      "nextServed":
                                                          _dateFormat.format(
                                                              meal.nextServed!)
                                                    }))
                                              : const SizedBox(height: 0),
                                          meal.numberOfOccurance != null
                                              ? Text(FlutterI18n.translate(
                                                  context,
                                                  "mealDetails.frequency",
                                                  translationParams: {
                                                      "frequency": meal
                                                          .numberOfOccurance
                                                          .toString()
                                                    }))
                                              : const SizedBox(height: 0),
                                        ],
                                      ),
                                    ),
                                  )))
                        ],
                      ),
                    )));
              }
            case Failure<Meal, NoMealException> _:
              {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mealSnapshot.error.toString())));
                Navigator.of(context).pop();
                return Container(
                  color: themeData.brightness == Brightness.light
                      ? themeData.colorScheme.background
                      : themeData.colorScheme.background,
                );
              }
          }
        });
  }
}
