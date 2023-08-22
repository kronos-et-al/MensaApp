import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_meal.dart';
import 'package:app/model/database/model/db_side.dart';

import 'db_meal_plan.dart';

class DBMealPlanSide implements DatabaseModel {
  final String _mealPlanID;
  final String _mealID;
  final String _sideID;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  /// The name of the table in the database.
  static const String tableName = 'mealPlanSide';

  /// The name of the column for the meal plan id.
  static const String columnMealPlanID = 'mealPlanID';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the side id.
  static const String columnSideID = 'sideID';

  /// The name of the column for the price for a student.
  static const String columnPriceStudent = 'priceStudent';

  /// The name of the column for the price for an employee.
  static const String columnPriceEmployee = 'priceEmployee';

  /// The name of the column for the price for a pupil.
  static const String columnPricePupil = 'pricePupil';

  /// The name of the column for the price for a guest.
  static const String columnPriceGuest = 'priceGuest';

  /// Creates a new instance of a meal plan side as it is represented in the database.
  DBMealPlanSide(
      this._mealPlanID,
      this._mealID,
      this._sideID,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealPlanID: _mealPlanID,
      columnMealID: _mealID,
      columnSideID: _sideID,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest
    };
  }

  /// Creates a new instance of a meal plan side from a map.
  static DBMealPlanSide fromMap(Map<String, dynamic> map) {
    return DBMealPlanSide(
        map[columnMealPlanID],
        map[columnMealID],
        map[columnSideID],
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest]);
  }

  /// The string to create a table for a meal plan side.
  static String initTable() {
    return 'CREATE TABLE $tableName('
        '$columnMealPlanID TEXT,'
        '$columnMealID TEXT,'
        '$columnSideID TEXT,'
        '$columnPriceStudent INTEGER,'
        '$columnPriceEmployee INTEGER,'
        '$columnPricePupil INTEGER,'
        '$columnPriceGuest INTEGER,'
        'PRIMARY KEY ($columnMealPlanID, $columnMealID, $columnSideID),'
        'FOREIGN KEY ($columnMealPlanID) REFERENCES ${DBMealPlan.tableName}(${DBMealPlan.columnMealPlanID}),'
        'FOREIGN KEY ($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID}),'
        'FOREIGN KEY ($columnSideID) REFERENCES ${DBSide.tableName}(${DBSide.columnSideID})'
        ')';
  }

  /// Returns the id of the meal plan of the side.
  String get mealPlanID => _mealPlanID;

  /// Returns the id of the meal of the side.
  String get mealID => _mealID;

  /// Returns the id of the side.
  String get sideID => _sideID;

  /// Returns the price for a student.
  int get priceStudent => _priceStudent;

  /// Returns the price for an employee.
  int get priceEmployee => _priceEmployee;

  /// Returns the price for a pupil.
  int get pricePupil => _pricePupil;

  /// Returns the price for a guest.
  int get priceGuest => _priceGuest;
}
