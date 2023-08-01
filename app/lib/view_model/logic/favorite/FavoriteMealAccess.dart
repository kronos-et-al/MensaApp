import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/material.dart';

/// This class is the interface for the access to the favorite meals data that are stored in the database.
class FavoriteMealAccess extends ChangeNotifier implements IFavoriteMealAccess {
  final IDatabaseAccess _database;

  late List<Meal> _favorites;

  // waits until _init() is finished initializing
  late Future _doneInitialization;

  /// Stores the access to the database and loads the values that are stored there.
  FavoriteMealAccess(this._database) {
    _doneInitialization = _init();
  }

  Future<void> _init() async {
    _favorites = await _database.getFavorites();
  }

  @override
  Future<void> addFavoriteMeal(Meal meal) async {
    await _doneInitialization;

    if (await isFavoriteMeal(meal)) {
      return;
    }

    await _database.addFavorite(meal);
    _favorites.add(meal);
    meal.setFavorite();
    notifyListeners();
  }

  @override
  Future<List<Meal>> getFavoriteMeals() async {
    await _doneInitialization;
    return Future.value(_favorites);
  }

  @override
  Future<bool> isFavoriteMeal(Meal meal) async {
    await _doneInitialization;
    return Future.value(
        _favorites.map((favorite) => favorite.id).contains(meal.id));
  }

  @override
  Future<void> removeFavoriteMeal(Meal meal) async {
    await _doneInitialization;

    if (await isFavoriteMeal(meal) == false) {
      return;
    }

    await _database.deleteFavorite(meal);
    _favorites.removeWhere((element) => element.id == meal.id);
    meal.deleteFavorite();
    notifyListeners();
  }
}
