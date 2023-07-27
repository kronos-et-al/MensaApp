import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaCtaButton.dart';
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
import 'package:app/view/detail_view/RatingsOverview.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class DetailsPage extends StatefulWidget {
  final Meal _meal;
  final Line? _line;

  DetailsPage({super.key, required Meal meal, Line? line})
      : _meal = meal,
        _line = line;

  @override
  State<StatefulWidget> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  int? expandedAccordionIndex;

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MensaIconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: NavigationBackIcon()),
                    Spacer(),
                    Consumer<IFavoriteMealAccess>(builder: (context, favoriteMealAccess, child) => MensaIconButton(
                        onPressed: () => {
                          favoriteMealAccess.addFavoriteMeal(widget._meal)
                        },
                        icon: widget._meal.isFavorite ? FavoriteFilledIcon() : FavoriteOutlinedIcon())),
                    MensaIconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: NavigationAddImageIcon()),
                  ],
                )),
          ),
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      widget._meal.name,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ))
                  ])),
              SizedBox(height: 16),
              Expanded(
                  child: Container(
                      color: themeData.brightness == Brightness.light
                          ? themeData.colorScheme.background
                          : themeData.colorScheme.surface,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget._line != null
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: MealLineIcon(),
                                        ),
                                        Text(
                                          widget._line!.name,
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    )
                                  : SizedBox(),
                              SizedBox(height: 8),
                              MealPreviewImage(
                                  borderRadius: BorderRadius.circular(4),
                                  meal: widget._meal,
                                  height: 250),
                              SizedBox(height: 8),
                              MealAccordion(
                                backgroundColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.background
                                        : themeData.colorScheme.surface,
                                expandedColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.surface
                                        : themeData.colorScheme.background,
                                mainEntry: MealMainEntry(meal: widget._meal),
                                info: MealAccordionInfo(
                                    additives: widget._meal.additives ?? [],
                                    allergens: widget._meal.allergens ?? []),
                                isExpanded: expandedAccordionIndex == 0,
                                onTap: () => setState(() =>
                                    expandedAccordionIndex =
                                        expandedAccordionIndex == 0 ? null : 0),
                              ),
                              ...?widget._meal.sides
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
                                            additives: e.additives ?? [],
                                            allergens: e.allergens ?? []),
                                        isExpanded: expandedAccordionIndex ==
                                            widget._meal.sides!.indexOf(e) + 1,
                                        onTap: () => setState(() =>
                                            expandedAccordionIndex =
                                                expandedAccordionIndex ==
                                                        widget._meal.sides!
                                                                .indexOf(e) +
                                                            1
                                                    ? null
                                                    : widget._meal.sides!
                                                            .indexOf(e) +
                                                        1),
                                      ))
                                  .toList(),
                              SizedBox(height: 16),
                              RatingsOverview(
                                meal: widget._meal,
                                backgroundColor:
                                    themeData.brightness == Brightness.light
                                        ? themeData.colorScheme.surface
                                        : themeData.colorScheme.background,
                              ),
                              SizedBox(height: 16),
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
                                  value: widget._meal.individualRating
                                          ?.toDouble() ?? 0,
                                  disabled: true,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                  max: 5,
                                  onChanged: (int) {},
                                ),
                                Spacer(),
                                MensaButton(text: FlutterI18n.translate(context, "ratings.editRating"), onPressed: null,)
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
