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

  /// Creates a new instance of a meal as it is represented in the database.
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
        map[columnAverageRating],
        map[columnLastServed],
        map[columnNextServed],
        Frequency.values.byName(map[columnRelativeFrequency]));
  }

  /// The string to create a table for a meal.
  static String initTable() {
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

  /// This method is used to get the relative frequency.
  Frequency get relativeFrequency => _relativeFrequency;

  /// This method is used to get the date when the meal will be served next.
  String get nextServed => _nextServed;

  /// This method is used to get the date when the meal was last served.
  String get lastServed => _lastServed;

  /// This method is used to get the average rating of the meal.
  double get averageRating => _averageRating;

  /// This method is used to get the number of ratings.
  int get numberOfRatings => _numberOfRatings;

  /// This method is used to get the individual rating of the meal.
  int get individualRating => _individualRating;

  /// This method is used to get the price for guests.
  int get priceGuest => _priceGuest;

  /// This method is used to get the price for pupils.
  int get pricePupil => _pricePupil;

  /// This method is used to get the price for employees.
  int get priceEmployee => _priceEmployee;

  /// This method is used to get the price for students.
  int get priceStudent => _priceStudent;

  /// This method is used to get the food type of the meal.
  FoodType get foodType => _foodType;

  /// This method is used to get the name of the meal.
  String get name => _name;

  /// This method is used to get the meal plan id.
  String get mealPlanID => _mealPlanID;

  /// This method is used to get the meal id.
  String get mealID => _mealID;
}
