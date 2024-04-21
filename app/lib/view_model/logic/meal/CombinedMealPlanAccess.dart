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

import '../../repository/data_classes/filter/Sorting.dart';
import '../../repository/data_classes/meal/Side.dart';

/// This class is the interface for the access to the meal data. The access can be done via the database or the server.
class CombinedMealPlanAccess extends ChangeNotifier implements IMealAccess {
  final ILocalStorage _preferences;
  final IServerAccess _api;
  final IDatabaseAccess _database;

  late Canteen _activeCanteen;
  late DateTime _displayedDate;
  late List<MealPlan> _filteredMealPlan;
  late FilterPreferences _filter;
  List<MealPlan> _mealPlans = List<MealPlan>.empty(growable: true);
  bool _noDataYet = false;
  bool _activeFilter = true;

  late PriceCategory _priceCategory;

  // waits until _init() is finished initializing
  late Future _doneInitialization;

  /// Stores the access to the api and database and loads the meal plan.
  /// @param preferences The access to the local storage.
  /// @param api The access to the api.
  /// @param database The access to the database.
  /// @return A new instance of the class.
  CombinedMealPlanAccess(this._preferences, this._api, this._database) {
    _doneInitialization = _init();
  }

  @override
  Future<void> reInit() async {
    _doneInitialization = _init();
    return _doneInitialization;
  }

  Future<void> _init() async {
    _displayedDate = DateTime.now();
    _filter = _preferences.getFilterPreferences() ?? FilterPreferences();
    _priceCategory = _preferences.getPriceCategory() ?? PriceCategory.student;

    // get canteen from string
    // get canteen id from local storage
    final canteenString = _preferences.getCanteen();
    Canteen? canteen;
    // get default canteen from server if canteen id not saved in local storage
    if (canteenString == null ||
        canteenString.isEmpty ||
        await _database.getCanteenById(canteenString) == null) {
      canteen = await _api.getDefaultCanteen();

      // save canteen id in local storage
      if (canteen != null) {
        failedInitializing = false;
        await _database.updateCanteen(canteen);
        _preferences.setCanteen(canteen.id);
      } else {
        failedInitializing = true;
        _noDataYet = false;
        _mealPlans = [];
      }
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

    // get meal plans form server
    if (_mealPlans.isEmpty) {
      print("loading initial day");
      await refreshMealplan();
      print("initial day loaded");
      refreshAll();
    } else {
      await _setNewMealPlan();
      refreshAll();
    }
  }

  Future<void> refreshAll() async {
    List<MealPlan> mealPlans = switch (await _api.updateAll()) {
      Success(value: final mealplan) => mealplan,
      Failure(exception: final exception) =>
        _convertMealPlanExceptionToMealPlan(exception)
    };

    // update all if connection to server is successful
    if (mealPlans.isNotEmpty) {
      await _database.updateAll(mealPlans);
    }
    _mealPlans = switch (
        await _database.getMealPlan(_displayedDate, _activeCanteen)) {
      Success(value: final mealplan) => mealplan,
      Failure() => []
    };

    await _setNewMealPlan();
    _database.cleanUp();
  }

  @override
  Future<void> changeCanteen(Canteen canteen) async {
    await _doneInitialization;
    _activeCanteen = canteen;
    _preferences.setCanteen(_activeCanteen.id);

    // requests and stores the new meal plan
    // filters meal plan
    // notifies listener
    await _setNewMealPlan();
    notifyListeners();
  }

  @override
  Future<void> changeDate(DateTime date) async {
    await _doneInitialization;
    _displayedDate = date;

    // requests and stores the new meal plan
    // filters meal plan
    // notifies listener
    await _setNewMealPlan();
    notifyListeners();
  }

  @override
  Future<void> changeFilterPreferences(
      FilterPreferences filterPreferences) async {
    await _doneInitialization;

    _activeFilter = true;

    _filter = filterPreferences;
    await _preferences.setFilterPreferences(_filter);
    await _filterMealPlans();

    notifyListeners();
  }

  @override
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan() async {
    await _doneInitialization;

    await _updateFavorites();
    await _filterMealPlans();

    // no data for date
    if (_noDataYet) {
      return Future.value(Failure(NoDataException("no data to date")));
    }

    // no connection to server and no data
    if (_mealPlans.isEmpty) {
      return Future.value(Failure(NoConnectionException("no connection")));
    }

    // canteen is closed
    bool closed = true;
    for (final mealPlan in _mealPlans) {
      if (!mealPlan.isClosed) {
        closed = false;
        break;
      }
    }

    if (closed) {
      return Future.value(Failure(ClosedCanteenException("canteen closed")));
    }

    if (!_activeFilter) {
      return Future.value(Success(_mealPlans));
    }

    // everything is filtered
    if (_filteredMealPlan.isEmpty) {
      return Future.value(Failure(FilteredMealException("all filtered")));
    }

    // success
    return Future.value(Success(_filteredMealPlan));
  }

  @override
  Future<Result<Meal, NoMealException>> getMeal(Meal meal) async {
    await _doneInitialization;

    for (final mealPlan in _mealPlans) {
      for (final e in mealPlan.meals) {
        if (e.id == meal.id) {
          return Success(meal);
        }
      }
    }

    return _database.getMeal(meal);
  }

  @override
  Future<String?> refreshMealplan() async {
    DateTime requestingDate = _displayedDate.copyWith();

    final mealPlan = await _getMealPlanFromServer();

    if (mealPlan.isEmpty) {
      return "snackbar.refreshMealPlanError";
    }

    await _database.updateAll(mealPlan);

    if (requestingDate != _displayedDate) return null;

    _mealPlans = mealPlan;

    await _updateFavorites();

    await _filterMealPlans();
    _removeUselessLines();

    notifyListeners();
    return null;
  }

  void _removeUselessLines() {
    _mealPlans = _mealPlans.where((element) => !element.isClosed).toList();
  }

  @override
  Future<bool> updateMealRating(int rating, Meal meal) async {
    await _doneInitialization;

    final result = await _api.updateMealRating(rating, meal);

    if (!result) {
      return false;
    }

    _changeRatingOfMeal(meal, rating);
    notifyListeners();
    return true;
  }

  @override
  Future<Canteen> getCanteen() async {
    await _doneInitialization;

    return _activeCanteen;
  }

  @override
  Future<List<Canteen>> getAvailableCanteens() async {
    await _doneInitialization;

    return (await _database.getCanteens()) ??
        (await _api.getCanteens()) ??
        List<Canteen>.empty();
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
    await _preferences.setFilterPreferences(_filter);
    await _filterMealPlans();
    notifyListeners();
  }

  @override
  Future<void> switchToMealPlanView() async {
    await _doneInitialization;

    bool changed = await _updateFavorites();
    final category = _preferences.getPriceCategory();

    // check if changed
    if (category != null && category != _priceCategory) {
      _priceCategory = category;
      changed = true;
    }

    // refresh if changed
    if (changed) {
      await _filterMealPlans();
      notifyListeners();
    }
  }

  @override
  Future<void> activateFilter() async {
    await _doneInitialization;

    if (_activeFilter) {
      return;
    }

    _activeFilter = true;
    notifyListeners();
  }

  @override
  Future<void> deactivateFilter() async {
    await _doneInitialization;

    if (!_activeFilter) {
      return;
    }

    _removeUselessLines();

    _activeFilter = false;
    notifyListeners();
  }

  @override
  Future<void> toggleFilter() async {
    await _doneInitialization;

    if (_activeFilter) {
      await deactivateFilter();
    } else {
      await activateFilter();
    }
  }

  Future<void> _changeRatingOfMeal(Meal changedMeal, int rating) async {
    int numberOfRatings = changedMeal.numberOfRatings;
    double newRating;

    if (changedMeal.individualRating == 0) {
      // change number of Ratings
      numberOfRatings += 1;

      // change average rating
      newRating =
          (changedMeal.averageRating * changedMeal.numberOfRatings + rating) /
              numberOfRatings;
    } else {
      // change average rating
      newRating = (changedMeal.averageRating * changedMeal.numberOfRatings -
              changedMeal.individualRating +
              rating) /
          numberOfRatings;
    }

    Meal newMeal = Meal.copy(
        meal: changedMeal,
        averageRating: newRating,
        numberOfRatings: numberOfRatings,
        individualRating: rating);
    await _database.updateMeal(newMeal);
    changedMeal.averageRating = newRating;
    changedMeal.numberOfRatings = numberOfRatings;
    changedMeal.individualRating = rating;
    notifyListeners();
  }

  Future<void> _filterMealPlans() async {
    _filteredMealPlan = [];
    // any kind of failure so no data is present
    if (_mealPlans.isEmpty || _noDataYet) {
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

      if (filteredMealPlan.meals.isNotEmpty) {
        newFilteredMealPlans.add(filteredMealPlan);
      }
    }

    if (newFilteredMealPlans.isEmpty) {
      _filteredMealPlan = List<MealPlan>.empty();
      return;
    }
    _filteredMealPlan = _sort(newFilteredMealPlans);
  }

  List<MealPlan> _sort(List<MealPlan> mealPlans) {
    List<MealPlan> sort = List<MealPlan>.empty(growable: true);
    List<MealPlan> sorted = List<MealPlan>.empty(growable: true);

    // check if sorted by
    if (_filter.sortedBy == Sorting.line) {
      if (_filter.ascending) {
        return mealPlans;
      }

      List<MealPlan> reversed = List<MealPlan>.empty(growable: true);
      for (MealPlan mealPlan in mealPlans) {
        reversed.add(MealPlan.copy(
            mealPlan: mealPlan, meals: List.from(mealPlan.meals.reversed)));
      }
      return List.from(reversed.reversed);
    }

    // give each meal is own meal plan for sorting
    for (final mealPlan in mealPlans) {
      for (final meal in mealPlan.meals) {
        sort.add(MealPlan.copy(mealPlan: mealPlan, meals: [meal]));
      }
    }

    // sort
    switch (_filter.sortedBy) {
      case Sorting.price:
        final category =
            _preferences.getPriceCategory() ?? PriceCategory.student;
        sort.sort((a, b) => a.meals[0].price
            .getPrice(category)
            .compareTo(b.meals[0].price.getPrice(category)));
      case Sorting.rating:
        sort.sort((a, b) =>
            a.meals[0].averageRating.compareTo(b.meals[0].averageRating));
      default:
        sort.sort((a, b) =>
            a.meals[0].numberOfOccurance
                ?.compareTo(b.meals[0].numberOfOccurance ?? 0) ??
            0);
    }

    // add same lines after each other to one

    MealPlan? lastMealPlan;
    for (final mealPlan in sort) {
      // first plan
      if (lastMealPlan == null) {
        lastMealPlan = mealPlan;
        continue;
      }

      // same line
      if (lastMealPlan.line.id == mealPlan.line.id) {
        lastMealPlan.meals.addAll(mealPlan.meals);
        continue;
      }

      // different line
      sorted.add(lastMealPlan);
      lastMealPlan = mealPlan;
    }

    sorted.add(lastMealPlan!);

    // sort ascending
    if (_filter.ascending) {
      return sorted;
    }

    //sort descending
    List<MealPlan> reversed = List<MealPlan>.empty(growable: true);
    for (MealPlan mealPlan in sorted) {
      reversed.add(MealPlan.copy(
          mealPlan: mealPlan, meals: List.from(mealPlan.meals.reversed)));
    }
    return List.from(reversed.reversed);
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
    final price = side.price.getPrice(_priceCategory);
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

    final price = meal.price
        .getPrice(_preferences.getPriceCategory() ?? PriceCategory.student);

    // check price
    if (_filter.price < price) {
      return false;
    }

    // check rating
    if (meal.averageRating != 0 &&
        meal.averageRating < _filter.rating.toDouble()) {
      return false;
    }

    // check frequency
    if (meal.relativeFrequency == null ||
        !_filter.frequency.contains(meal.relativeFrequency)) {
      return false;
    }

    // check onlyFavorite
    if (_filter.onlyFavorite && !meal.isFavorite) {
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

    await _updateFavorites();

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

  Future<bool> _updateFavorites() async {
    final favorites = await _database.getFavorites();
    bool changed = false;

    for (final mealPlan in _mealPlans) {
      for (final meal in mealPlan.meals) {
        if (favorites.any((favorite) => favorite.meal.id == meal.id)) {
          meal.setFavorite();
          changed = true;
        } else {
          meal.deleteFavorite();
          changed = true;
        }
      }
    }

    return changed;
  }

  @override
  Future<bool> isFilterActive() async {
    return Future.value(_activeFilter);
  }

  @override
  bool failedInitializing = false;
}
