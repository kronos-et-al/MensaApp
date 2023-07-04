import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:flutter/cupertino.dart';

import '../../repository/data_classes/meal/Meal.dart';
import '../../repository/data_classes/mealplan/Canteen.dart';
import '../../repository/error_handling/Result.dart';

/// This class is the interface for the access to the meal data. The access can be done via the database or the server.
abstract class IMealAccess {
  /// This method requests the mealplan of the committed canteen for the committed day from the database.
  /// If the requested data is not stored there, the data is requested from the server.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @return The mealplan of the committed date of the committed canteen or an error
  Future<Result<List<Mealplan>>> getMealPlan(DateTime date, Canteen canteen);

  /// This method returns the meal with the committed id form the database.
  /// If the requested data is not stored there, the data is requested from the server.
  /// @param id The id of the meal
  /// @return The meal with the committed id or an error
  Future<Result<Meal>> getMealFromId(String id);

  /// This method updates all meal plans of the committed date of the committed canteen.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> refreshMealplan(DateTime date, Canteen canteen, BuildContext context);

  /// This method updates the rating of the committed meal on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param rating The new rating of the meal
  /// @param meal The meal that should be updated
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> updateMealRating(int rating, Meal meal, BuildContext context);

  /// This method changes the FilterPreferences of the app.
  /// @param filterPreferences The new FilterPreferences
  /// @return The result of the update
  Future<void> changeFilterPreferences(FilterPreferences filterPreferences);

  /// This method changes the last used canteen that is stored.
  /// @param canteen The new canteen
  /// @return The result of the update
  Future<void> changeCanteen(Canteen canteen);

  /// This method changes the date of the mealplan that is displayed.
  /// @param date The new date
  /// @return The result of the update
  Future<void> changeDate(DateTime date);
}