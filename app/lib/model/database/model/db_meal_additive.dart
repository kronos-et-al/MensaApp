import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';

import 'db_meal.dart';

class DBMealAdditive implements DatabaseModel {

  final String _mealID;
  final Additive _additive;

  static const String tableName = 'mealAdditive';

  static const String columnMealID = 'mealID';
  static const String columnAdditive = 'additive';

  DBMealAdditive(this._mealID, this._additive);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealID: _mealID,
      columnAdditive: _additive
    };
  }

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

  Additive get additive => _additive;

  String get mealID => _mealID;
}