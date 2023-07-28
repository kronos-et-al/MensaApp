import 'package:app/model/database/model/database_model.dart';

import '../../../view_model/repository/data_classes/filter/Frequency.dart';
import '../../../view_model/repository/data_classes/meal/FoodType.dart';
import 'db_meal_plan.dart';

class DBMeal implements DatabaseModel {

  final String _mealID;
  final String _mealPlanID;
  final String _name;
  final FoodType _foodType;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;
  final int _individualRating;
  final int _numberOfRatings;
  final double _averageRating;
  final String _lastServed;
  final String _nextServed;
  final Frequency _relativeFrequency;

  static const String tableName = 'meal';

  static const String columnMealID = 'mealID';
  static const String columnMealPlanID = 'mealPlanID';
  static const String columnName = 'name';
  static const String columnFoodType = 'foodType';
  static const String columnPriceStudent = 'priceStudent';
  static const String columnPriceEmployee = 'priceEmployee';
  static const String columnPricePupil = 'pricePupil';
  static const String columnPriceGuest = 'priceGuest';
  static const String columnIndividualRating = 'individualRating';
  static const String columnNumberOfRatings = 'numberOfRatings';
  static const String columnAverageRating = 'averageRating';
  static const String columnLastServed = 'lastServed';
  static const String columnNextServed = 'nextServed';
  static const String columnRelativeFrequency = 'relativeFrequency';

  DBMeal(this._mealID, this._mealPlanID, this._name, this._foodType, this._priceStudent, this._priceEmployee, this._pricePupil, this._priceGuest, this._individualRating, this._numberOfRatings, this._averageRating, this._lastServed, this._nextServed, this._relativeFrequency);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealID: _mealID,
      columnMealPlanID: _mealPlanID,
      columnName: _name,
      columnFoodType: _foodType.name,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest,
      columnIndividualRating: _individualRating,
      columnNumberOfRatings: _numberOfRatings,
      columnAverageRating: _averageRating,
      columnLastServed: _lastServed,
      columnNextServed: _nextServed,
      columnRelativeFrequency: _relativeFrequency.name
    };
  }

  static DBMeal fromMap(Map<String, dynamic> map) {
    return DBMeal(map[columnMealID], map[columnMealPlanID], map[columnName], FoodType.values.byName(map[columnFoodType]), map[columnPriceStudent], map[columnPriceEmployee], map[columnPricePupil], map[columnPriceGuest], map[columnIndividualRating], map[columnNumberOfRatings], map[columnAverageRating], map[columnLastServed], map[columnNextServed], Frequency.values.byName(map[columnRelativeFrequency]));
  }

  static String initTable() {
    /// The string to create a table for a meal.
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT PRIMARY KEY,
      $columnMealPlanID TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnFoodType TEXT NOT NULL,
      $columnPriceStudent INTEGER NOT NULL CHECK($columnPriceStudent >= 0),
      $columnPriceEmployee INTEGER NOT NULL CHECK($columnPriceEmployee >= 0),
      $columnPricePupil INTEGER NOT NULL CHECK($columnPricePupil >= 0),
      $columnPriceGuest INTEGER NOT NULL CHECK($columnPriceGuest >= 0),
      $columnIndividualRating INTEGER,
      $columnNumberOfRatings INTEGER NOT NULL,
      $columnAverageRating DECIMAL(1,1),
      $columnLastServed TEXT NOT NULL,
      $columnNextServed TEXT,
      $columnRelativeFrequency TEXT,
      FOREIGN KEY($columnMealPlanID) REFERENCES ${DBMealPlan.tableName}(${DBMealPlan.columnMealPlanID})
    )
  ''';
  }

  Frequency get relativeFrequency => _relativeFrequency;

  String get nextServed => _nextServed;

  String get lastServed => _lastServed;

  double get averageRating => _averageRating;

  int get numberOfRatings => _numberOfRatings;

  int get individualRating => _individualRating;

  int get priceGuest => _priceGuest;

  int get pricePupil => _pricePupil;

  int get priceEmployee => _priceEmployee;

  int get priceStudent => _priceStudent;

  FoodType get foodType => _foodType;

  String get name => _name;

  String get mealPlanID => _mealPlanID;

  String get mealID => _mealID;
}