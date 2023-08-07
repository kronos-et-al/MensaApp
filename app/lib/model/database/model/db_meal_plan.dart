import 'package:app/model/database/model/database_model.dart';

import 'db_line.dart';

/// This class represents a meal plan in the database.
class DBMealPlan implements DatabaseModel {
  final String _mealPlanID;
  final String _lineID;
  final String _date;
  final bool _isClosed;

  /// The name of the table in the database.
  static const String tableName = 'mealPlan';

  /// The name of the column for the meal plan id.
  static const String columnMealPlanID = 'mealPlanID';

  /// The name of the column for the line id.
  static const String columnLineID = 'lineID';

  /// The name of the column for the date.
  static const String columnDate = 'date';

  /// The name of the column that stores if the line is closed.
  static const String columnIsClosed = 'isClosed';

  /// Creates a new instance of a meal plan.
  /// @param _mealPlanID The id of the meal plan.
  /// @param _lineID The id of the line.
  /// @param _date The date of the meal plan.
  /// @param _isClosed If the line is closed.
  /// @returns A new instance of a meal plan.
  DBMealPlan(this._mealPlanID, this._lineID, this._date, this._isClosed);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealPlanID: _mealPlanID,
      columnLineID: _lineID,
      columnDate: _date,
      columnIsClosed: _isClosed ? 1 : 0
    };
  }

  /// Creates a new instance of a meal plan from a map.
  /// @param map The map to create the instance from.
  /// @returns A new instance of a meal plan.
  static DBMealPlan fromMap(Map<String, dynamic> map) {
    return DBMealPlan(map[columnMealPlanID], map[columnLineID], map[columnDate],
        map[columnIsClosed] == 1);
  }

  /// The string to create a table for a meal plan.
  /// @returns The string to create a table for a meal plan.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealPlanID TEXT PRIMARY KEY NOT NULL,
      $columnLineID TEXT NOT NULL,
      $columnDate TEXT,
      $columnIsClosed NUMBER NOT NULL,
      FOREIGN KEY($columnLineID) REFERENCES ${DBLine.tableName}(${DBLine.columnLineID}),
      UNIQUE($columnLineID, $columnDate)
    )
  ''';
  }

  /// This method returns if the line is closed.
  /// @returns If the line is closed.
  bool get isClosed => _isClosed;

  /// This method returns the date of the meal plan.
  /// @returns The date of the meal plan.
  String get date => _date;

  /// This method returns the id of the line.
  /// @returns The id of the line.
  String get lineID => _lineID;

  /// This method returns the id of the meal plan.
  /// @returns The id of the meal plan.
  String get mealPlanID => _mealPlanID;
}
