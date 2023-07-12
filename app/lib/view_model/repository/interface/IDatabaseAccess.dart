import 'package:app/view_model/repository/error_handling/MealPlanException.dart';

import '../data_classes/meal/Meal.dart';
import '../data_classes/mealplan/Canteen.dart';
import '../data_classes/mealplan/MealPlan.dart';
import '../error_handling/Result.dart';

/// This is an interface to the database of the client.
abstract class IDatabaseAccess {
  /// This method updates all mealplans with the committed mealplans.
  /// @param mealplans The mealplans that should be updated
  /// @return The result of the update
  Future<void> updateAll(List<MealPlan> mealplans);

  /// This method returns the mealplan of the committed date of the committed canteen.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @return The mealplan of the committed date of the committed canteen or an error
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan(DateTime date, Canteen canteen);

  /// This method returns a favorite meal.
  /// @param id The id of the meal
  /// @return The favorite meal with the committed id or an error
  Future<Result<Meal, Exception>> getMealFavorite(String id);

  /// This method adds a favorite. If the favorite does already exists, it does nothing.
  /// @param meal The meal that should be added as favorite
  /// @return The result of the update
  Future<void> addFavorite(Meal meal);

  /// This method removes a favorite. If the favorite does not exists, it does nothing.
  /// @param meal The meal that should be removed as favorite
  /// @return The result of the update
  Future<void> deleteFavorite(Meal meal);

  /// This method returns all Favorites.
  /// @return all Favorites
  Future<List<Meal>> getFavorites();

  /// This method returns the canteen with the committed id.
  Future<Canteen> getCanteenById(String id);
}