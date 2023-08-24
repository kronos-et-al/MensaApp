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
  final int? _frequency;
  final Frequency _relativeFrequency;

  /// The name of the table in the database.
  static const String tableName = 'mealPlanMeal';

  /// The name of the column for the meal plan id.
  static const String columnMealPlanID = 'mealPlanID';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the price for a student.
  static const String columnPriceStudent = 'priceStudent';

  /// The name of the column for the price for an employee.
  static const String columnPriceEmployee = 'priceEmployee';

  /// The name of the column for the price for a pupil.
  static const String columnPricePupil = 'pricePupil';

  /// The name of the column for the price for a guest.
  static const String columnPriceGuest = 'priceGuest';

  /// The name of the column for the date when the meal was last served.
  static const String columnLastServed = 'lastServed';

  /// The name of the column for the date when the meal will be served next.
  static const String columnNextServed = 'nextServed';

  /// The name of the column that stores the frequency.
  static const String columnFrequency = 'frequency';

  /// The name of the column that stores the relative frequency.
  static const String columnRelativeFrequency = 'relativeFrequency';

  /// Creates a new instance of a meal plan meal as it is represented in the database.
  DBMealPlanMeal(
      this._mealPlanID,
      this._mealID,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest,
      this._lastServed,
      this._nextServed,
      this._frequency,
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
      columnFrequency: _frequency,
      columnRelativeFrequency: _relativeFrequency.name
    };
  }

  /// Creates a new instance of a meal plan meal from a map.
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
        map[columnFrequency],
        Frequency.values.byName(map[columnRelativeFrequency]));
  }

  /// The string to create a table for a meal plan meal.
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
        '$columnFrequency INTEGER, '
        '$columnRelativeFrequency TEXT, '
        'PRIMARY KEY ($columnMealPlanID, $columnMealID), '
        'FOREIGN KEY ($columnMealPlanID) REFERENCES ${DBMealPlan.tableName}(${DBMealPlan.columnMealPlanID}), '
        'FOREIGN KEY ($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID})'
        ')';
  }

  /// Returns the meal plan id.
  String get mealPlanID => _mealPlanID;

  /// Returns the meal id.
  String get mealID => _mealID;

  /// Returns the price for students.
  int get priceStudent => _priceStudent;

  /// Returns the price for employees.
  int get priceEmployee => _priceEmployee;

  /// Returns the price for pupils.
  int get pricePupil => _pricePupil;

  /// Returns the price for guests.
  int get priceGuest => _priceGuest;

  /// Returns the date when the meal was last served.
  String get lastServed => _lastServed;

  /// Returns the data when the meal will be served next.
  String get nextServed => _nextServed;

  /// Returns the frequency of the meal.
  int? get frequency => _frequency;

  /// Returns the relative frequency of the meal.
  Frequency get relativeFrequency => _relativeFrequency;
}
