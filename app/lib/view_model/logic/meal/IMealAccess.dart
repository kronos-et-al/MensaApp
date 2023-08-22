import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:flutter/cupertino.dart';

import '../../repository/data_classes/meal/Meal.dart';
import '../../repository/data_classes/mealplan/Canteen.dart';
import '../../repository/error_handling/Result.dart';

/// This class is the interface for the access to the meal data. The access can be done via the database or the server.
abstract class IMealAccess with ChangeNotifier {
  /// This method requests the mealplan of the stored canteen for the stored day from the database.
  /// If the requested data is not stored there, the data is requested from the server.
  ///
  /// Return the meal plan of the committed date of the committed canteen or an [MealPlanException].
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan();

  /// This method returns the meal with the committed id form the database or current mealplan.
  ///
  Future<Result<Meal, NoMealException>> getMeal(Meal meal);

  /// This method updates all meal plans of the committed date of the committed canteen.
  /// It returns a string that should be displayed in a temporal message or null if no string should be displayed.
  ///
  /// Returns a string that should be displayed in a temporal message or null .
  Future<String?> refreshMealplan();

  /// This method updates the rating of the committed meal on the server.
  /// Returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  Future<String> updateMealRating(int rating, Meal meal);

  /// Returns the currently selected [FilterPreferences].
  Future<FilterPreferences> getFilterPreferences();

  /// Resets the [FilterPreferences].
  Future<void> resetFilterPreferences();

  /// Changes the [FilterPreferences] of the app.
  Future<void> changeFilterPreferences(FilterPreferences filterPreferences);

  /// Returns the currently selected [Canteen].
  Future<Canteen> getCanteen();

  /// Returns all available canteens.
  Future<List<Canteen>> getAvailableCanteens();

  /// Changes the last used canteen that is stored.
  Future<void> changeCanteen(Canteen canteen);

  /// Returns the currently displayed date.
  Future<DateTime> getDate();

  /// Changes the date of the mealplan that is displayed.
  Future<void> changeDate(DateTime date);

  /// This method checks if settings or favorites are changed since the last time the mealplan was displayed.
  /// If they were changed it corrects the displayed data if needed.
  Future<void> switchToMealPlanView();

  /// Activate the filter.
  Future<void> activateFilter();

  /// Deactivate the filter.
  Future<void> deactivateFilter();

  /// Toggle the activity of a filter.
  Future<void> toggleFilter();

  Future<bool> isFilterActive();

  Future<void> removeImage(ImageData image);
}
