import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';

import 'db_meal.dart';
import 'db_meal_plan.dart';

class DBMealPlanMeal implements DatabaseModel {
  final String _mealPlanID;
  final String _mealID;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;
  final String _lastServed;
  final String _nextServed;
  final Frequency _relativeFrequency;

  static const String tableName = 'mealPlanMeal';

  static const String columnMealPlanID = 'mealPlanID';
  static const String columnMealID = 'mealID';
  static const String columnPriceStudent = 'priceStudent';
  static const String columnPriceEmployee = 'priceEmployee';
  static const String columnPricePupil = 'pricePupil';
  static const String columnPriceGuest = 'priceGuest';
  static const String columnLastServed = 'lastServed';
  static const String columnNextServed = 'nextServed';
  static const String columnRelativeFrequency = 'relativeFrequency';

  DBMealPlanMeal(
      this._mealPlanID,
      this._mealID,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest,
      this._lastServed,
      this._nextServed,
      this._relativeFrequency);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealPlanID: _mealPlanID,
      columnMealID: _mealID,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest,
      columnLastServed: _lastServed,
      columnNextServed: _nextServed,
      columnRelativeFrequency: _relativeFrequency.name
    };
  }

  static DBMealPlanMeal fromMap(Map<String, dynamic> map) {
    return DBMealPlanMeal(
        map[columnMealPlanID],
        map[columnMealID],
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest],
        map[columnLastServed],
        map[columnNextServed],
        Frequency.values.byName(map[columnRelativeFrequency]));
  }

  static String initTable() {
    return 'CREATE TABLE $tableName('
        '$columnMealPlanID TEXT, '
        '$columnMealID TEXT, '
        '$columnPriceStudent INTEGER, '
        '$columnPriceEmployee INTEGER, '
        '$columnPricePupil INTEGER, '
        '$columnPriceGuest INTEGER, '
        '$columnLastServed TEXT, '
        '$columnNextServed TEXT, '
        '$columnRelativeFrequency TEXT, '
        'PRIMARY KEY ($columnMealPlanID, $columnMealID), '
        'FOREIGN KEY ($columnMealPlanID) REFERENCES ${DBMealPlan.tableName}(${DBMealPlan.columnMealPlanID}), '
        'FOREIGN KEY ($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID})'
        ')';
  }

  String get mealPlanID => _mealPlanID;

  String get mealID => _mealID;

  int get priceStudent => _priceStudent;

  int get priceEmployee => _priceEmployee;

  int get pricePupil => _pricePupil;

  int get priceGuest => _priceGuest;

  String get lastServed => _lastServed;

  String get nextServed => _nextServed;

  Frequency get relativeFrequency => _relativeFrequency;
}
