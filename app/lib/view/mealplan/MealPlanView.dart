import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/navigation/NavigationFilterOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationGridOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationListOutlinedIcon.dart';
import 'package:app/view/core/meal_view_format/MealGrid.dart';
import 'package:app/view/core/meal_view_format/MealList.dart';
import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view/mealplan/MealPlanClosed.dart';
import 'package:app/view/mealplan/MealPlanDateSelect.dart';
import 'package:app/view/mealplan/MealPlanError.dart';
import 'package:app/view/mealplan/MealPlanFilter.dart';
import 'package:app/view/mealplan/MealPlanNoData.dart';
import 'package:app/view/mealplan/MealPlanToolbar.dart';
import 'package:app/view/mealplan/MensaCanteenSelect.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:provider/provider.dart';

class MealPlanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IPreferenceAccess>(
        builder: (context, preferenceAccess, child) =>
            Consumer<IMealAccess>(builder: (context, mealAccess, child) {
              return FutureBuilder(
                  future: Future.wait([
                    preferenceAccess.getMealPlanFormat(),
                    mealAccess.getCanteen(),
                    mealAccess.getAvailableCanteens(),
                    mealAccess.getDate(),
                    mealAccess.getMealPlan(),
                  ], eagerError: true),
                  builder: (context, snapshot) {
                    print(snapshot.data.toString());
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) return const MealPlanError();
                    MealPlanFormat mealPlanFormat =
                        snapshot.requireData[0] as MealPlanFormat;
                    Canteen selectedCanteen =
                        snapshot.requireData[1] as Canteen;
                    List<Canteen> availableCanteens =
                        snapshot.requireData[2] as List<Canteen>;
                    DateTime date = snapshot.requireData[3] as DateTime;
                    Result<List<MealPlan>, MealPlanException> mealPlans =
                        snapshot.requireData[4]
                            as Result<List<MealPlan>, MealPlanException>;
                    return Scaffold(
                        appBar: MensaAppBar(
                          appBarHeight: kToolbarHeight * 1.25,
                          bottom: MealPlanToolbar(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      MensaTapable(
                                          child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: mealPlanFormat ==
                                                      MealPlanFormat.grid
                                                  ? const NavigationListOutlinedIcon()
                                                  : const NavigationGridOutlinedIcon()),
                                          onTap: () {
                                            preferenceAccess.setMealPlanFormat(
                                                mealPlanFormat ==
                                                        MealPlanFormat.grid
                                                    ? MealPlanFormat.list
                                                    : MealPlanFormat.grid);
                                          }),
                                      const Spacer(),
                                      MealPlanDateSelect(
                                        date: date,
                                        onDateChanged: (date) =>
                                            mealAccess.changeDate(date),
                                      ),
                                      const Spacer(),
                                      MensaTapable(
                                          child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child:
                                                  NavigationFilterOutlinedIcon()),
                                          onTap: () => {})
                                    ],
                                  ))),
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Row(children: [
                                Expanded(
                                    child: MensaCanteenSelect(
                                        selectedCanteen: selectedCanteen,
                                        availableCanteens: availableCanteens,
                                        onCanteenSelected: (canteen) =>
                                            mealAccess.changeCanteen(canteen)))
                              ])),
                        ),
                        body: RefreshIndicator(
                          onRefresh: () async {
                            String? error = await mealAccess.refreshMealplan();
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: I18nText(error)));
                            }
                          },
                          child: (() {
                            switch (mealPlans) {
                              case Success<List<MealPlan>, MealPlanException>
                                value:
                                return mealPlanFormat == MealPlanFormat.grid
                                    ? MealGrid(mealPlans: value.value)
                                    : MealList(mealPlans: value.value);
                              case Failure<List<MealPlan>, MealPlanException>
                                exception:
                                if (exception.exception
                                    is NoConnectionException) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: const MealPlanError()),
                                  );
                                }
                                if (exception.exception is NoDataException) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: const MealPlanNoData()),
                                  );
                                }
                                if (exception.exception
                                    is ClosedCanteenException) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: const MealPlanClosed()),
                                  );
                                }
                                if (exception.exception
                                    is FilteredMealException) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: const MealPlanFilter()),
                                  );
                                }
                                return SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: const MealPlanError()),
                                );
                            }
                          }()),
                        ));
                  });
            }));
  }
}
