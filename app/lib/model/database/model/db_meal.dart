import 'dart:ffi';

import 'package:app/model/database/model/database_model.dart';

import '../../../view_model/repository/data_classes/filter/Frequency.dart';
import '../../../view_model/repository/data_classes/meal/FoodType.dart';
import 'db_meal_plan.dart';

/// This class represents a meal in the database.
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

  /// The name of the table in the database.
  static const String tableName = 'meal';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the meal plan id.
  static const String columnMealPlanID = 'mealPlanID';

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

  /// The name of the column for the individual rating.
  static const String columnIndividualRating = 'individualRating';

  /// The name of the column for the number of ratings.
  static const String columnNumberOfRatings = 'numberOfRatings';

  /// The name of the column for the average rating.
  static const String columnAverageRating = 'averageRating';

  /// The name of the column for the last served date.
  static const String columnLastServed = 'lastServed';

  /// The name of the column for the next served date.
  static const String columnNextServed = 'nextServed';

  /// The name of the column for the relative frequency.
  static const String columnRelativeFrequency = 'relativeFrequency';

  /// Creates a new instance of a meal.
  /// @param _mealID The id of the meal.
  /// @param _mealPlanID The id of the meal plan.
  /// @param _name The name of the meal.
  /// @param _foodType The food type of the meal.
  /// @param _priceStudent The price for students.
  /// @param _priceEmployee The price for employees.
  /// @param _pricePupil The price for pupils.
  /// @param _priceGuest The price for guests.
  /// @param _individualRating The individual rating.
  /// @param _numberOfRatings The number of ratings.
  /// @param _averageRating The average rating.
  /// @param _lastServed The last served date.
  /// @param _nextServed The next served date.
  /// @param _relativeFrequency The relative frequency.
  /// @return A new instance of a meal.
  DBMeal(
      this._mealID,
      this._mealPlanID,
      this._name,
      this._foodType,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest,
      this._individualRating,
      this._numberOfRatings,
      this._averageRating,
      this._lastServed,
      this._nextServed,
      this._relativeFrequency);

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

  /// Creates a new instance of a meal from a map.
  /// @param map The map to create a meal from.
  /// @return A new instance of a meal.
  static DBMeal fromMap(Map<String, dynamic> map) {
    return DBMeal(
        map[columnMealID],
        map[columnMealPlanID],
        map[columnName],
        FoodType.values.byName(map[columnFoodType]),
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest],
        map[columnIndividualRating],
        map[columnNumberOfRatings],
        _checkDouble(map[columnAverageRating]) ?? 0,
        map[columnLastServed],
        map[columnNextServed],
        Frequency.values.byName(map[columnRelativeFrequency]));
  }

  /// The string to create a table for a meal.
  /// @return The string to create a table for a meal.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT NOT NULL,
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
      FOREIGN KEY($columnMealPlanID) REFERENCES ${DBMealPlan.tableName}(${DBMealPlan.columnMealPlanID}),
      PRIMARY KEY($columnMealPlanID, $columnMealID)
    )
  ''';
  }

  /// This method is used to get the relative frequency.
  /// @return The relative frequency.
  Frequency get relativeFrequency => _relativeFrequency;

  /// This method is used to get the date when the meal will be served next.
  /// @return The date when the meal will be served next.
  String get nextServed => _nextServed;

  /// This method is used to get the date when the meal was last served.
  /// @return The date when the meal was last served.
  String get lastServed => _lastServed;

  /// This method is used to get the average rating of the meal.
  /// @return The average rating of the meal.
  double get averageRating => _averageRating;

  /// This method is used to get the number of ratings.
  /// @return The number of ratings.
  int get numberOfRatings => _numberOfRatings;

  /// This method is used to get the individual rating of the meal.
  /// @return The individual rating of the meal.
  int get individualRating => _individualRating;

  /// This method is used to get the price for guests.
  /// @return The price for guests.
  int get priceGuest => _priceGuest;

  /// This method is used to get the price for pupils.
  /// @return The price for pupils.
  int get pricePupil => _pricePupil;

  /// This method is used to get the price for employees.
  /// @return The price for employees.
  int get priceEmployee => _priceEmployee;

  /// This method is used to get the price for students.
  /// @return The price for students.
  int get priceStudent => _priceStudent;

  /// This method is used to get the food type of the meal.
  /// @return The food type of the meal.
  FoodType get foodType => _foodType;

  /// This method is used to get the name of the meal.
  /// @return The name of the meal.
  String get name => _name;

  /// This method is used to get the meal plan id.
  /// @return The meal plan id.
  String get mealPlanID => _mealPlanID;

  /// This method is used to get the meal id.
  /// @return The meal id.
  String get mealID => _mealID;

  static double? _checkDouble(dynamic value) {
    if(value is double) return value;
    if(value is int) return value.toDouble();
    if(value is String) return double.tryParse(value);
    return null;
  }
}
