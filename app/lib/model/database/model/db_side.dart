import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

import 'database_model.dart';
import 'db_meal.dart';

/// This class represents a side in the database.
class DBSide implements DatabaseModel {
  final String _sideID;
  final String _mealID;
  final String _name;
  final FoodType _foodType;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  /// The name of the table in the database.
  static const String tableName = 'side';

  /// The name of the column for the side id.
  static const String columnSideID = 'sideID';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the name.
  static const String columnName = 'name';

  /// The name of the column for the food type.
  static const String columnFoodType = 'foodType';

  /// The name of the column for the price for students.
  static const String columnPriceStudent = 'priceStudent';

  /// The name of the column for the price for employees.
  static const String columnPriceEmployee = 'priceEmployee';

  /// The name of the column for the price for pupils.
  static const String columnPricePupil = 'pricePupil';

  /// The name of the column for the price for guests.
  static const String columnPriceGuest = 'priceGuest';

  /// Creates a new instance of a side as it is represented in the Database.
  DBSide(
      this._sideID,
      this._mealID,
      this._name,
      this._foodType,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest);

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

  /// Creates a side from a map.
  static DBSide fromMap(Map<String, dynamic> map) {
    return DBSide(
        map[columnSideID],
        map[columnMealID],
        map[columnName],
        map[columnFoodType],
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest]);
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

  /// Returns the price for a guest.
  int get priceGuest => _priceGuest;

  /// Returns the price for a pupil.
  int get pricePupil => _pricePupil;

  /// Returns the price for an employee.
  int get priceEmployee => _priceEmployee;

  /// Returns the price for a student.
  int get priceStudent => _priceStudent;

  /// Returns the food type of the side.
  FoodType get foodType => _foodType;

  /// Returns the name of the side.
  String get name => _name;

  /// Returns the id of the meal.
  String get mealID => _mealID;

  /// Returns the id of the side.
  String get sideID => _sideID;
}
