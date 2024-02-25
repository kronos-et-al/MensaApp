import 'package:app/model/database/model/database_model.dart';

/// This class represents a meal's nutrition data in the database.
class DBMealNutritionData implements DatabaseModel {
  final String _mealID;
  final int _energy;
  final int _protein;
  final int _carbohydrates;
  final int _sugar;
  final int _fat;
  final int _saturatedFat;
  final int _salt;

  /// The name of the table in the database.
  static const String tableName = 'mealNutritionData';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the food's energy.
  static const String columnEnergy = 'energy';

  /// The name of the column for the food's proteins.
  static const String columnProtein = 'protein';

  /// The name of the column for the food's carbohydrates.
  static const String columnCarbohydrates = 'carbohydrates';

  /// The name of the column for the food's sugar.
  static const String columnSugar = 'sugar';

  /// The name of the column for the food's fat.
  static const String columnFat = 'fat';

  /// The name of the column for the food's saturatedFat.
  static const String columnSaturatedFat = 'saturatedFat';

  /// The name of the column for the food's salt.
  static const String columnSalt = 'salt';

  /// Creates a new instance of a nutrition data object.
  DBMealNutritionData(this._mealID, this._energy, this._protein, this._carbohydrates, this._sugar, this._fat, this._saturatedFat, this._salt);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealID: _mealID,
      columnEnergy: _energy,
      columnProtein: _protein,
      columnCarbohydrates: _carbohydrates,
      columnSugar: _sugar,
      columnFat: _fat,
      columnSaturatedFat: _saturatedFat,
      columnSalt: _salt,
    };
  }

  /// Creates a new instance of a nutrition data object from a map.
  static DBMealNutritionData fromMap(Map<String, dynamic> map) {
    return DBMealNutritionData(
        map[columnMealID],
        map[columnEnergy],
        map[columnProtein],
        map[columnCarbohydrates],
        map[columnSugar],
        map[columnFat],
        map[columnSaturatedFat],
        map[columnSalt],
    );
  }

  /// Returns a string to create a table for nutrition data.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT PRIMARY KEY,
      $columnEnergy INTEGER,
      $columnProtein INTEGER,
      $columnCarbohydrates INTEGER,
      $columnSugar INTEGER,
      $columnFat INTEGER,
      $columnSaturatedFat INTEGER,
      $columnSalt INTEGER
    );
  ''';
  }


  String get mealID => _mealID;

  int get energy => _energy;

  int get protein => _protein;

  int get carbohydrates => _carbohydrates;

  int get sugar => _sugar;

  int get fat => _fat;

  int get saturatedFat => _saturatedFat;

  int get salt => _salt;
}
