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

  static const String tableName = 'mealPlanSide';

  static const String columnMealPlanID = 'mealPlanID';
  static const String columnMealID = 'mealID';
  static const String columnSideID = 'sideID';
  static const String columnPriceStudent = 'priceStudent';
  static const String columnPriceEmployee = 'priceEmployee';
  static const String columnPricePupil = 'pricePupil';
  static const String columnPriceGuest = 'priceGuest';

  DBMealPlanSide(this._mealPlanID, this._mealID, this._sideID, this._priceStudent, this._priceEmployee, this._pricePupil, this._priceGuest);

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

  static DBMealPlanSide fromMap(Map<String, dynamic> map) {
    return DBMealPlanSide(
      map[columnMealPlanID],
      map[columnMealID],
      map[columnSideID],
      map[columnPriceStudent],
      map[columnPriceEmployee],
      map[columnPricePupil],
      map[columnPriceGuest]
    );
  }

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

  String get mealPlanID => _mealPlanID;

  String get mealID => _mealID;

  String get sideID => _sideID;

  int get priceStudent => _priceStudent;

  int get priceEmployee => _priceEmployee;

  int get pricePupil => _pricePupil;

  int get priceGuest => _priceGuest;

}