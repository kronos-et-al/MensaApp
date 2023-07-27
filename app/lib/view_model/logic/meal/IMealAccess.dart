import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:flutter/cupertino.dart';

import '../../repository/data_classes/meal/Meal.dart';
import '../../repository/data_classes/mealplan/Canteen.dart';
import '../../repository/error_handling/Result.dart';

/// This class is the interface for the access to the meal data. The access can be done via the database or the server.
abstract class IMealAccess with ChangeNotifier {
  /// This method requests the mealplan of the committed canteen for the committed day from the database.
  /// If the requested data is not stored there, the data is requested from the server.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @return The mealplan of the committed date of the committed canteen or an error
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan();

  /// This method returns the meal with the committed id form the database.
  /// If the requested data is not stored there, the data is requested from the server.
  /// @param id The id of the meal
  /// @return The meal with the committed id or an error
  Future<Result<Meal, Exception>> getWholeFavorite(String id);

  /// This method updates all meal plans of the committed date of the committed canteen.
  /// It returns a string that should be displayed in a temporal message or null.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @param context The context of the app used for displaying temporal messages.
  /// @return It returns a string that should be displayed in a temporal message or null.
  Future<String?> refreshMealplan();

  /// This method updates the rating of the committed meal on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  /// @param rating The new rating of the meal
  /// @param meal The meal that should be updated
  /// @param context The context of the app used for displaying temporal messages.
  /// @return It returns a string that should be displayed in a temporal message.
  Future<String> updateMealRating(int rating, Meal meal);

  /// This method returns the currently selected filter preferences.
  /// @return The selected filter preferences.
  Future<FilterPreferences> getFilterPreferences();

  /// This method resets the filter preferences.
  Future<void> resetFilterPreferences();

  /// This method changes the FilterPreferences of the app.
  /// @param filterPreferences The new FilterPreferences
  /// @return The result of the update
  Future<void> changeFilterPreferences(FilterPreferences filterPreferences);

  /// This method returns the currently selected Canteen.
  /// @return The currently selected Canteen.
  Future<Canteen> getCanteen();

  /// This method returns all available canteens.
  /// @return All available canteens.
  Future<List<Canteen>> getAvailableCanteens();

  /// This method changes the last used canteen that is stored.
  /// @param canteen The new canteen
  /// @return The result of the update
  Future<void> changeCanteen(Canteen canteen);

  /// This method returns the currently displayed date.
  /// @return The current displayed date.
  Future<DateTime> getDate();

  /// This method changes the date of the mealplan that is displayed.
  /// @param date The new date
  /// @return The result of the update
  Future<void> changeDate(DateTime date);

  /// This method checks if settings or favorites are changed since the last time the mealplan was displayed.
  /// If they were changed it corrects the displayed data if needed.
  Future<void> switchToMealPlanView();

  /// This method activates the filter.
  /// @return The result of the update
  Future<void> activateFilter();

  /// This method deactivates the filter.
  /// @return The result of the update
  Future<void> deactivateFilter();

  Future<void> toggleFilter();
}
