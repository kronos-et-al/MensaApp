import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';

import 'db_meal.dart';

/// This class represents an additive of a meal in the database.
class DBMealAdditive implements DatabaseModel {
  final String _mealID;
  final Additive _additive;

  /// The name of the table in the database.
  static const String tableName = 'mealAdditive';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the additive.
  static const String columnAdditive = 'additive';

  /// Creates a new instance of a meal additive as it is represented in the database.
  DBMealAdditive(this._mealID, this._additive);

  @override
  Map<String, dynamic> toMap() {
    return {columnMealID: _mealID, columnAdditive: _additive.name};
  }

  /// Creates a new instance of a meal additive from a map.
  static DBMealAdditive fromMap(Map<String, dynamic> map) {
    return DBMealAdditive(map[columnMealID], map[columnAdditive]);
  }

  /// The string to create a table for an additive of a meal.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT,
      $columnAdditive TEXT,
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID}),
      PRIMARY KEY($columnMealID, $columnAdditive)
    )
  ''';
  }

  /// Returns the additive of the meal.
  Additive get additive => _additive;

  /// Returns the id of the meal.
  String get mealID => _mealID;
}
