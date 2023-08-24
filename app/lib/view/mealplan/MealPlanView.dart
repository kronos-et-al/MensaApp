import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/navigation/NavigationFilterOutlinedDisabledIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationFilterOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationGridOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationListOutlinedIcon.dart';
import 'package:app/view/core/meal_view_format/MealGrid.dart';
import 'package:app/view/core/meal_view_format/MealList.dart';
import 'package:app/view/filter/FilterDialog.dart';
import 'package:app/view/mealplan/MealPlanClosed.dart';
import 'package:app/view/mealplan/MealPlanDateSelect.dart';
import 'package:app/view/mealplan/MealPlanError.dart';
import 'package:app/view/mealplan/MealPlanFilter.dart';
import 'package:app/view/mealplan/MealPlanNoData.dart';
import 'package:app/view/mealplan/MealPlanToolbar.dart';
import 'package:app/view/mealplan/MensaCanteenSelect.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This class is the view for the meal plan.
class MealPlanView extends StatelessWidget {
  /// Creates a new meal plan view.
  const MealPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    IImageAccess imageAccess = Provider.of<IImageAccess>(context);
    IFavoriteMealAccess favoriteMealAccess =
        Provider.of<IFavoriteMealAccess>(context);
    ThemeData theme = Theme.of(context);
    return Consumer<IFavoriteMealAccess>(
        builder: (context, favoriteMealAccess, child) => Consumer<
                IPreferenceAccess>(
            builder: (context, preferenceAccess, child) =>
                Consumer<IMealAccess>(builder: (context, mealAccess, child) {
                  return FutureBuilder(
                      future: Future.wait([
                        mealAccess.getCanteen(),
                        mealAccess.getAvailableCanteens(),
                        mealAccess.getDate(),
                        mealAccess.getMealPlan(),
                        mealAccess.isFilterActive()
                      ], eagerError: true),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) return const MealPlanError();
                        MealPlanFormat mealPlanFormat =
                            preferenceAccess.getMealPlanFormat();
                        Canteen selectedCanteen =
                            snapshot.requireData[0] as Canteen;
                        List<Canteen> availableCanteens =
                            snapshot.requireData[1] as List<Canteen>;
                        DateTime date = snapshot.requireData[2] as DateTime;
                        Result<List<MealPlan>, MealPlanException> mealPlans =
                            snapshot.requireData[3]
                                as Result<List<MealPlan>, MealPlanException>;
                        bool filterActive = snapshot.requireData[4] as bool;
                        if (availableCanteens.indexWhere((element) =>
                                element.id == selectedCanteen.id) ==
                            -1) {
                          mealAccess.changeCanteen(availableCanteens[0]);
                        }
                        return Scaffold(
                            appBar: MensaAppBar(
                              appBarHeight: kToolbarHeight,
                              bottom: MealPlanToolbar(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          MensaTapable(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: mealPlanFormat ==
                                                          MealPlanFormat.grid
                                                      ? const NavigationListOutlinedIcon()
                                                      : const NavigationGridOutlinedIcon()),
                                              onTap: () {
                                                preferenceAccess
                                                    .setMealPlanFormat(
                                                        mealPlanFormat ==
                                                                MealPlanFormat
                                                                    .grid
                                                            ? MealPlanFormat
                                                                .list
                                                            : MealPlanFormat
                                                                .grid);
                                              }),
                                          const Spacer(),
                                          MealPlanDateSelect(
                                            date: date,
                                            onDateChanged: (date) =>
                                                mealAccess.changeDate(date),
                                          ),
                                          const Spacer(),
                                          MensaTapable(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: filterActive
                                                      ? const NavigationFilterOutlinedIcon()
                                                      : const NavigationFilterOutlinedDisabledIcon()),
                                              onLongPress: () => {
                                                    mealAccess.toggleFilter(),
                                                  },
                                              onTap: () => {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          const FilterDialog(),
                                                    )
                                                  })
                                        ],
                                      ))),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Row(children: [
                                    Expanded(
                                        child: MensaCanteenSelect(
                                            selectedCanteen: selectedCanteen,
                                            availableCanteens:
                                                availableCanteens,
                                            onCanteenSelected: (canteen) =>
                                                mealAccess
                                                    .changeCanteen(canteen)))
                                  ])),
                            ),
                            body: RefreshIndicator(
                              onRefresh: () async {
                                String? error =
                                    await mealAccess.refreshMealplan();
                                if (!context.mounted) return;
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                            FlutterI18n.translate(
                                                context, error),
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.onError),
                                          ),
                                          backgroundColor:
                                              theme.colorScheme.error));
                                }
                              },
                              child: (() {
                                switch (mealPlans) {
                                  case Success<List<MealPlan>,
                                        MealPlanException> value:
                                    return mealPlanFormat == MealPlanFormat.grid
                                        ? MealGrid(mealPlans: value.value)
                                        : MealList(mealPlans: value.value);
                                  case Failure<List<MealPlan>,
                                        MealPlanException> exception:
                                    if (exception.exception
                                        is NoConnectionException) {
                                      return const MealPlanError();
                                    }
                                    if (exception.exception
                                        is NoDataException) {
                                      return const MealPlanNoData();
                                    }
                                    if (exception.exception
                                        is ClosedCanteenException) {
                                      return const MealPlanClosed();
                                    }
                                    if (exception.exception
                                        is FilteredMealException) {
                                      return const MealPlanFilter();
                                    }
                                    return const MealPlanError();
                                }
                              }()),
                            ));
                      });
                })));
  }
}
