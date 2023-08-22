import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';

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

  /// Changes the meal with the id of the committed meal in the database to the committed meal.
  Future<void> updateMeal(Meal meal);

  /// Returns the [MealPlan] of the committed date of the committed canteen.
  /// If the mealplan does not exists, it returns an [MealPlanException].
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan(
      DateTime date, Canteen canteen);

  /// Returns the meal with the id of the committed meal.
  /// This method is used for applying changes on the graphical user interface.
  Future<Result<Meal, NoMealException>> getMeal(Meal meal);

  /// Returns the favorite meal with the committed id.
  /// If the [Meal] is not a favorite, it returns an [Exception].
  Future<Result<Meal, Exception>> getMealFavorite(String id);

  /// This method adds a favorite. If the favorite does already exists, it does nothing.
  /// @param meal The meal that should be added as favorite
  /// @return The result of the update
  Future<void> addFavorite(Meal meal);

  /// This method removes a favorite.
  /// If the favorite does not exists, it does nothing.
  Future<void> deleteFavorite(Meal meal);

  /// Returns all Favorites.
  Future<List<Meal>> getFavorites();

  /// This method returns the canteen with the committed id.
  /// If no canteen with the committed id exists, it returns 'null'.
  Future<Canteen> getCanteenById(String id);

  /// This method returns all canteens or null if no canteen is stored.
  Future<List<Canteen>?> getCanteens();

  Future<void> removeImage(ImageData image);
}
