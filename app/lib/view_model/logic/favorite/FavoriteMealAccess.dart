
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/material.dart';

class FavoriteMealAccess extends ChangeNotifier implements IFavoriteMealAccess {
  final IDatabaseAccess _database;

  late List<Meal> _favorites;

  FavoriteMealAccess(this._database) {
    _init();
  }
  
  Future<void> _init() async {
    _favorites = await _database.getFavorites();
  }

  @override
  Future<void> addFavoriteMeal(Meal meal) async {
    if (await isFavoriteMeal(meal)) {
      return;
    }

    await _database.addFavorite(meal);
    _favorites.add(meal);
    notifyListeners();
  }

  @override
  Future<List<Meal>> getFavoriteMeals() async {
    return Future.value(_favorites);
  }

  @override
  Future<bool> isFavoriteMeal(Meal meal) async {
    return Future.value(_favorites.map((favorite) => favorite.id).contains(meal.id));
  }

  @override
  Future<void> removeFavoriteMeal(Meal meal) async {
    if (await isFavoriteMeal(meal) == false) {
      return;
    }

    await _database.deleteFavorite(meal);
    _favorites.removeWhere((element) => element.id == meal.id);
    notifyListeners();
  }

}