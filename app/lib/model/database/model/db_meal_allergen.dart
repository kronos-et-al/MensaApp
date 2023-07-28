import 'package:app/model/database/model/database_model.dart';

import '../../../view_model/repository/data_classes/meal/Allergen.dart';
import 'db_meal.dart';

/// This class represents an allergen of a meal in the database.
class DBMealAllergen implements DatabaseModel {
  final String _mealID;
  final Allergen _allergen;

  /// The name of the table in the database.
  static const String tableName = 'mealAllergen';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the allergen.
  static const String columnAllergen = 'allergen';

  /// Creates a new instance of a meal allergen.
  /// @param _mealID The id of the meal.
  /// @param _allergen The allergen of the meal.
  /// @returns A new instance of a meal allergen.
  DBMealAllergen(this._mealID, this._allergen);

  @override
  Map<String, dynamic> toMap() {
    return {columnMealID: _mealID, columnAllergen: _allergen.name};
  }

  /// Creates a new instance of a meal allergen from a map.
  /// @param map The map to create the instance from.
  /// @returns A new instance of a meal allergen.
  static DBMealAllergen fromMap(Map<String, dynamic> map) {
    return DBMealAllergen(
        map[columnMealID], Allergen.values.byName(map[columnAllergen]));
  }

  /// The string to create a table for an allergen of a meal.
  /// @returns The string to create a table for an allergen of a meal.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT,
      $columnAllergen TEXT,
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID}),
      PRIMARY KEY($columnMealID, $columnAllergen)
    )
  ''';
  }

  /// This method returns the allergen of the meal.
  /// @returns The allergen of the meal.
  Allergen get allergen => _allergen;

  /// This method returns the id of the meal.
  /// @returns The id of the meal.
  String get mealID => _mealID;
}
