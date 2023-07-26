import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

import 'database_model.dart';
import 'db_meal.dart';

class DBSide implements DatabaseModel {

  final String _sideID;
  final String _mealID;
  final String _name;
  final FoodType _foodType;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  static const String tableName = 'side';

  static const String columnSideID = 'sideID';
  static const String columnMealID = 'mealID';
  static const String columnName = 'name';
  static const String columnFoodType = 'foodType';
  static const String columnPriceStudent = 'priceStudent';
  static const String columnPriceEmployee = 'priceEmployee';
  static const String columnPricePupil = 'pricePupil';
  static const String columnPriceGuest = 'priceGuest';

  DBSide(this._sideID, this._mealID, this._name, this._foodType, this._priceStudent, this._priceEmployee, this._pricePupil, this._priceGuest);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnSideID: _sideID,
      columnMealID: _mealID,
      columnName: _name,
      columnFoodType: _foodType,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest
    };
  }

  static DBSide fromMap(Map<String, dynamic> map) {
    return DBSide(map[columnSideID], map[columnMealID], map[columnName], map[columnFoodType], map[columnPriceStudent], map[columnPriceEmployee], map[columnPricePupil], map[columnPriceGuest]);
  }

  /// The string to create a table for a side.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnSideID TEXT PRIMARY KEY,
      $columnMealID TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnFoodType TEXT NOT NULL,
      $columnPriceStudent INTEGER NOT NULL CHECK($columnPriceStudent >= 0),
      $columnPriceEmployee INTEGER NOT NULL CHECK($columnPriceEmployee >= 0),
      $columnPricePupil INTEGER NOT NULL CHECK($columnPricePupil >= 0),
      $columnPriceGuest INTEGER NOT NULL CHECK($columnPriceGuest >= 0),
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID})
    )
  ''';
  }

  int get priceGuest => _priceGuest;

  int get pricePupil => _pricePupil;

  int get priceEmployee => _priceEmployee;

  int get priceStudent => _priceStudent;

  FoodType get foodType => _foodType;

  String get name => _name;

  String get mealID => _mealID;

  String get sideID => _sideID;
}