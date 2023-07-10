
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/material.dart';

class CombinedMealPlanAccess extends ChangeNotifier implements IMealAccess {
  final ILocalStorage _preferences;
  final IServerAccess _api;
  final IDatabaseAccess _database;

  late Canteen _activeCanteen;
  late DateTime _displayedDate;
  late List<MealPlan> _mealplans = [];
  late List<MealPlan> _filteredMealplan;
  late FilterPreferences _filter;

  CombinedMealPlanAccess(
      this._preferences,
      this._api,
      this._database
  ) {
    _init();
  }


  Future<void> _init() async {
    _displayedDate = DateTime.timestamp();
    _filter = await _preferences.getFilterPreferences() ?? FilterPreferences();

    // get mealplans form server
    List<MealPlan> mealplans = switch (await _api.updateAll()) {
      Success(value: final mealplan) => mealplan,
      Failure(exception: final exception) => []
    };

    // update all if connection to server is successful
    if (mealplans.isNotEmpty) {
      _database.updateAll(mealplans);
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

    // if canteen can not be set, no mealplans can be displayed
    if (canteen == null) {
      _mealplans = [];
      _filteredMealplan = [];
      return;
    }

    _activeCanteen = canteen;

    // get mealplans from database
    // new if update was successful
    // old if update was not successful and old data is stored in the database
    // no mealplan if update was not successful and old data is not stored in database
    _mealplans = switch (await _database.getMealPlan(_displayedDate, canteen)) {
      Success(value: final mealplan) => mealplan,
      Failure(exception: final exception) => []
    };

    // filter mealplans
    _filterMealPlans();
  }

  @override
  Future<void> changeCanteen(Canteen canteen) async {
    _activeCanteen = canteen;
    _preferences.setCanteen(canteen.id);

    // TODO get new MealPlan

    notifyListeners();
  }

  @override
  Future<void> changeDate(DateTime date) async {
    _displayedDate = date;

    // TODO get new MealPlan

    notifyListeners();
  }

  @override
  Future<void> changeFilterPreferences(FilterPreferences filterPreferences) {
    // TODO: implement changeFilterPreferences
    throw UnimplementedError();
  }

  @override
  Future<Result<Meal, Exception>> getMealFromId(String id) {
    // TODO: implement getMealFromId
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan(DateTime date, Canteen canteen) async {
    if (date != _displayedDate || canteen != _activeCanteen) {
      await _setNewMealPlan(canteen, date);
    }

    // no connection to server and no data
    if (_mealplans.isEmpty) {
      return Future.value(Failure(NoConnectionException("no connection")));
    }

    // everything is filtered
    if (_filteredMealplan.isEmpty) {
      return Future.value(Failure(FilteredMealException("all filtered")));
    }

    // canteen is closed
    if (_mealplans.first.isClosed) {
      return Future.value(Failure(ClosedCanteenException("canteen closed")));
    }

    // no data for date
    if (_mealplans.first.meals.isEmpty) {
      return Future.value(Failure(NoDataException("no data to date")));
    }

    // success
    return Future.value(Success(_mealplans));
  }

  @override
  Future<void> refreshMealplan(DateTime date, Canteen canteen, BuildContext context) {
    // TODO: implement refreshMealplan
    throw UnimplementedError();
  }

  @override
  Future<void> updateMealRating(int rating, Meal meal, BuildContext context) {
    // TODO: implement updateMealRating
    throw UnimplementedError();
  }

  void _filterMealPlans() {
    if (_mealplans.isEmpty) {
      _filteredMealplan = [];
      return;
    }

    // TODO implement
    throw UnimplementedError();
  }

  /// This method stores the mealplan of the committed canteen and date in the _mealplan attribute and filters the mealplan.
  /// Therefore it checks first the database and if there is no data, it requests it from the server.
  Future<void> _setNewMealPlan(Canteen canteen, DateTime date) async {
    final mealplan = switch (await _database.getMealPlan(date, canteen)) {
      Success(value: final mealplans) => mealplans,
      Failure(exception: final exception) => null
    };

    _mealplans = mealplan ?? switch (await _api.updateCanteen(canteen, date)) {
      Success(value: final mealplans) => mealplans,
      Failure(exception: final exception) => []
    };

    _filterMealPlans();
    notifyListeners();
  }

}