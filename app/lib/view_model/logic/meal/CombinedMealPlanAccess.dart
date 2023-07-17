import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/material.dart';

import '../../repository/data_classes/meal/Side.dart';

// todo wann ist das Zeug wirklich zu? einfach rauslöschen?
// todo string for snack-bar
class CombinedMealPlanAccess extends ChangeNotifier implements IMealAccess {
  final ILocalStorage _preferences;
  final IServerAccess _api;
  final IDatabaseAccess _database;

  late Canteen _activeCanteen;
  late DateTime _displayedDate;
  late List<MealPlan> _mealPlans = [];
  late List<MealPlan> _filteredMealPlan;
  late FilterPreferences _filter;
  late bool _noDataYet = false;

  // waits until _init() is finished initializing
  late Future _doneInitialization;

  CombinedMealPlanAccess(this._preferences, this._api, this._database) {
    _doneInitialization = _init();
  }

  Future<void> _init() async {
    _displayedDate = DateTime.timestamp();
    _filter = await _preferences.getFilterPreferences() ?? FilterPreferences();

    // get meal plans form server
    List<MealPlan> mealPlans = switch (await _api.updateAll()) {
      Success(value: final mealplan) => mealplan,
      Failure() => []
    };

    // update all if connection to server is successful
    if (mealPlans.isNotEmpty) {
      _database.updateAll(mealPlans);
    }

    // get canteen from string
    // get canteen id from local storage
    final canteenString = await _preferences.getCanteen();
    Canteen? canteen;
    // get default canteen from server if canteen id not saved in local storage
    if (canteenString == null) {
      canteen = await _api.getDefaultCanteen();

      // save canteen id in local storage
      _preferences.setCanteen(canteen!.id);
    } else {
      // get canteen from database
      // updates from server are already stored or there is no connection
      canteen = await _database.getCanteenById(canteenString);
    }

    // if canteen can not be set, no meal plans can be displayed
    if (canteen == null) {
      _mealPlans = [];
      _filteredMealPlan = [];
      return;
    }

    _activeCanteen = canteen;

    // get meal plans from database
    // new if update was successful
    // old if update was not successful and old data is stored in the database
    // no meal-plan if update was not successful and old data is not stored in database
    _mealPlans = switch (await _database.getMealPlan(_displayedDate, canteen)) {
      Success(value: final mealplan) => mealplan,
      Failure() => []
    };

    // filter meal plans
    await _filterMealPlans();
  }

  @override
  Future<void> changeCanteen(Canteen canteen) async {
    await _doneInitialization;
    _activeCanteen = canteen;

    // requests and stores the new meal plan
    // filters meal plan
    // notifies listener
    await _setNewMealPlan();
  }

  @override
  Future<void> changeDate(DateTime date) async {
    await _doneInitialization;
    _displayedDate = date;

    // requests and stores the new meal plan
    // filters meal plan
    // notifies listener
    await _setNewMealPlan();
  }

  @override
  Future<void> changeFilterPreferences(
      FilterPreferences filterPreferences) async {
    await _doneInitialization;

    _filter = filterPreferences;
    await _filterMealPlans();

    notifyListeners();
  }

  @override
  Future<Result<Meal, Exception>> getWholeFavorite(String id) async {
    await _doneInitialization;

    final meal = switch (await _database.getMealFavorite(id)) {
      Success(value: final value) => value,
      Failure() => null
    };

    if (meal == null) {
      return Failure(NoMealException("no meal"));
    }

    final line = await _database.getFavoriteMealsLine(meal);
    final date = await _database.getFavoriteMealsDate(meal);

    if (line == null || date == null) {
      return Failure(NoMealException("no meal"));
    }

    final mealFromServer = switch (await _api.getMeal(meal, line, date)) {
      Success(value: final value) => value,
      Failure() => null
    };

    if (mealFromServer == null) {
      return Failure(NoMealException("no meal"));
    }

    return Success(mealFromServer);
  }

  @override
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan() async {
    await _doneInitialization;

    // no connection to server and no data
    if (_mealPlans.isEmpty) {
      return Future.value(Failure(NoConnectionException("no connection")));
    }

    // everything is filtered
    if (_filteredMealPlan.isEmpty) {
      return Future.value(Failure(FilteredMealException("all filtered")));
    }

    // canteen is closed
    if (_mealPlans.first.isClosed) {
      return Future.value(Failure(ClosedCanteenException("canteen closed")));
    }

    // no data for date
    if (_noDataYet) {
      return Future.value(Failure(NoDataException("no data to date")));
    }

    // success
    return Future.value(Success(_filteredMealPlan));
  }

  @override
  Future<String?> refreshMealplan() async {
    await _doneInitialization;

    final mealPlan = await _getMealPlanFromServer();

    if (_mealPlans.isEmpty) {
      return "error";
    }

    _mealPlans = mealPlan;
    await _filterMealPlans();

    notifyListeners();
    return null;
  }

  @override
  Future<String> updateMealRating(int rating, Meal meal) async {
    await _doneInitialization;

    final result = await _api.updateMealRating(rating, meal);

    if (!result) {
      return "error";
    }

    _changeRatingOfMeal(meal, rating);
    notifyListeners();
    return "success";
  }

  @override
  Future<Canteen> getCanteen() async {
    await _doneInitialization;

    return _activeCanteen;
  }

  @override
  Future<DateTime> getDate() async {
    await _doneInitialization;

    return _displayedDate;
  }

  @override
  Future<FilterPreferences> getFilterPreferences() async {
    await _doneInitialization;

    return _filter;
  }

  @override
  Future<void> resetFilterPreferences() async {
    await _doneInitialization;

    _filter = FilterPreferences();
    await _filterMealPlans();
  }

  void _changeRatingOfMeal(Meal changedMeal, int rating) {
    for (final mealPlan in _mealPlans) {
      // check if right meal plan
      final result =
          mealPlan.meals.map((meal) => meal.id).contains(changedMeal.id);

      if (result) {
        // remove outdated meal, add new meal
        mealPlan.meals.removeWhere((element) => element.id == changedMeal.id);
        mealPlan.meals
            .add(Meal.copy(meal: changedMeal, individualRating: rating));
        return;
      }
    }
  }

  Future<void> _filterMealPlans() async {
    _filteredMealPlan = [];
    // any kind of failure so no data is present
    if (_mealPlans.isEmpty || _noDataYet || _mealPlans.first.isClosed) {
      return;
    }

    List<MealPlan> newFilteredMealPlans = [];

    for (final mealPlan in _mealPlans) {
      MealPlan filteredMealPlan = MealPlan.copy(mealPlan: mealPlan, meals: []);

      for (final meal in mealPlan.meals) {
        // check if meal would be displayed
        if (await _filterMeal(meal)) {
          // add meal if displayed
          Meal filteredMeal = Meal.copy(meal: meal, sides: []);
          filteredMealPlan.meals.add(filteredMeal);

          // filter sides of copied meal
          await _filterSides(filteredMeal, meal.sides);
        }
      }

      if (mealPlan.meals.isNotEmpty) {
        newFilteredMealPlans.add(filteredMealPlan);
      }
    }

    _filteredMealPlan = newFilteredMealPlans;
  }

  Future<void> _filterSides(Meal meal, List<Side>? sides) async {
    if (sides == null) {
      return Future.value();
    }

    for (final side in sides) {
      if (await _filterSide(side)) {
        meal.sides!.add(side);
      }
    }
  }

  Future<bool> _filterSide(Side side) async {
    // check categories
    if (!_filter.categories.contains(side.foodType)) {
      return false;
    }

    // check allergens
    for (final allergen in side.allergens) {
      if (!_filter.allergens.contains(allergen)) {
        return false;
      }
    }

    // check price
    final price = side.price.getPrice(
        await _preferences.getPriceCategory() ?? PriceCategory.student);
    if (price > _filter.price) {
      return false;
    }

    return true;
  }

  Future<bool> _filterMeal(Meal meal) async {
    // check categories
    if (!_filter.categories.contains(meal.foodType)) {
      return false;
    }

    // check allergens
    if (meal.allergens != null) {
      final allergens = meal.allergens ?? [];
      for (final allergen in allergens) {
        if (!_filter.allergens.contains(allergen)) {
          return false;
        }
      }
    }

    final price = meal.price.getPrice(
        await _preferences.getPriceCategory() ?? PriceCategory.student);

    // check price
    if (_filter.price < price) {
      return false;
    }

    // check rating
    if (meal.averageRating != null && meal.averageRating! < _filter.rating) {
      return false;
    }

    // check frequency
    if (meal.relativeFrequency == null ||
        !_filter.frequency.contains(meal.relativeFrequency)) {
      return false;
    }

    // check onlyFavorite
    if (_filter.onlyFavorite &&
        !(await _database.getFavorites()).map((e) => e.id).contains(meal.id)) {
      return false;
    }

    return true;
  }

  /// This method stores the meal plan of the committed canteen and date in the _mealPlan attribute and filters the meal plan.
  /// It also notifies the listeners
  /// Therefore it checks first the database and if there is no data, it requests it from the server.
  Future<void> _setNewMealPlan() async {
    _noDataYet = false;
    _mealPlans = await _getMealPlanFromDatabaseAndServer();

    await _filterMealPlans();
    notifyListeners();
  }

  Future<List<MealPlan>> _getMealPlanFromDatabaseAndServer() async {
    final mealPlan =
        switch (await _database.getMealPlan(_displayedDate, _activeCanteen)) {
      Success(value: final mealplans) => mealplans,
      Failure(exception: final exception) =>
        _handleMealPlanErrorFromDatabase(exception)
    };

    if (mealPlan != null) {
      return mealPlan;
    }

    return await _getMealPlanFromServer();
  }

  List<MealPlan>? _handleMealPlanErrorFromDatabase(
      MealPlanException exception) {
    switch (exception) {
      case NoConnectionException():
        return [];
      case FilteredMealException():
        return [];
      case ClosedCanteenException():
        return [
          MealPlan(
              date: _displayedDate,
              line: Line(
                  id: "0", name: "name", canteen: _activeCanteen, position: 0),
              isClosed: true,
              meals: [])
        ];
      case NoDataException():
        return null;
    }
  }

  Future<List<MealPlan>> _getMealPlanFromServer() async {
    _noDataYet = false;
    return switch (await _api.updateCanteen(_activeCanteen, _displayedDate)) {
      Success(value: final mealplans) => mealplans,
      Failure(exception: final exception) =>
        _convertMealPlanExceptionToMealPlan(exception)
    };
  }

  List<MealPlan> _convertMealPlanExceptionToMealPlan(
      MealPlanException exception) {
    switch (exception) {
      case NoConnectionException():
        return [];
      case FilteredMealException():
        return [];
      case ClosedCanteenException():
        return [
          MealPlan(
              date: _displayedDate,
              line: Line(
                  id: "0", name: "name", canteen: _activeCanteen, position: 0),
              isClosed: true,
              meals: [])
        ];
      case NoDataException():
        _noDataYet = true;
        return [
          MealPlan(
              date: _displayedDate,
              line: Line(
                  id: "0", name: "name", canteen: _activeCanteen, position: 0),
              isClosed: false,
              meals: [])
        ];
    }
  }
}
