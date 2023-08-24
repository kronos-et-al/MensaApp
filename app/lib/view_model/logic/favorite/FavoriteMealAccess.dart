import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/material.dart';

/// This class is the interface for the access to the favorite meals data that are stored in the database.
class FavoriteMealAccess extends ChangeNotifier implements IFavoriteMealAccess {
  final IDatabaseAccess _database;
  final IServerAccess _api;

  late List<FavoriteMeal> _favorites;

  // waits until _init() is finished initializing
  late Future _doneInitialization;

  /// Stores the access to the database and loads the values that are stored there.
  FavoriteMealAccess(this._database, this._api) {
    _doneInitialization = _init();
  }

  Future<void> _init() async {
    final favorites = await _database.getFavorites();

    //update favorites
    for (final favorite in favorites) {
      final Meal? meal = switch (await _api.getMeal(favorite.meal, favorite.servedLine, favorite.servedDate)) {
        Success(value: final value) => value,
        Failure(exception: _) => null
      };

      if (meal != null) {
        _database.updateMeal(meal);
      }
    }

    _favorites = await _database.getFavorites();
  }

  @override
  Future<void> addFavoriteMeal(
      Meal meal, DateTime servedDate, Line servedLine) async {
    await _doneInitialization;

    if (await isFavoriteMeal(meal)) {
      return;
    }

    await _database.addFavorite(meal, servedDate, servedLine);
    _favorites = await _database.getFavorites();
    meal.setFavorite();
    notifyListeners();
  }

  @override
  Future<List<FavoriteMeal>> getFavoriteMeals() async {
    await _doneInitialization;
    return _favorites;
  }

  @override
  Future<bool> isFavoriteMeal(Meal meal) async {
    await _doneInitialization;
    return Future.value(
        _favorites.map((favorite) => favorite.meal.id).contains(meal.id));
  }

  @override
  Future<void> removeFavoriteMeal(Meal meal) async {
    await _doneInitialization;

    if (!_favorites.map((favorite) => favorite.meal.id).contains(meal.id)) {
      return;
    }

    await _database.deleteFavorite(meal);
    _favorites = await _database.getFavorites();
    meal.deleteFavorite();
    notifyListeners();
  }
}
