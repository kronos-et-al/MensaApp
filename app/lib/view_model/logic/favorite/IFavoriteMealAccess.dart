import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:flutter/material.dart';

import '../../repository/data_classes/meal/Meal.dart';

/// This class is the interface for the access to the favorite meals data.
abstract class IFavoriteMealAccess with ChangeNotifier {
  /// This method adds the committed meal to the favorite meals in the database.
  Future<void> addFavoriteMeal(Meal meal, DateTime servedDate, Line servedLine);

  /// This method removes the committed meal from the favorite meals in the database.
  Future<void> removeFavoriteMeal(Meal meal);

  /// This method checks if the committed meal is a favorite meal.
  /// Returns ture, if the meal is a favorite meal, false otherwise.
  Future<bool> isFavoriteMeal(Meal meal);

  /// Returns the favorite meals from the database.
  Future<List<FavoriteMeal>> getFavoriteMeals();
}
