import 'package:flutter/material.dart';

import '../../repository/data_classes/meal/Meal.dart';

/// This class is the interface for the access to the favorite meals data.
abstract class IFavoriteMealAccess with ChangeNotifier {
  /// This method adds the committed meal to the favorite meals in the database.
  /// @param meal The meal that should be added
  /// @return The result of the update
  Future<void> addFavoriteMeal(Meal meal);

  /// This method removes the committed meal from the favorite meals in the database.
  /// @param meal The meal that should be removed
  /// @return The result of the update
  Future<void> removeFavoriteMeal(Meal meal);

  /// This method checks if the committed meal is a favorite meal.
  /// @param meal The meal that should be checked
  /// @return ture, if the meal is a favorite meal, false otherwise
  Future<bool> isFavoriteMeal(Meal meal);

  /// This method returns the favorite meals from the database.
  /// @return The favorite meals or an error
  Future<List<Meal>> getFavoriteMeals();
}
