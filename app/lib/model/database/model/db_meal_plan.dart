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

  /// Creates a new instance of a meal plan as it is represented in the database.
  DBMealPlan(this._mealPlanID, this._lineID, this._date, this._isClosed);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealPlanID: _mealPlanID,
      columnLineID: _lineID,
      columnDate: _date,
      columnIsClosed: _isClosed
    };
  }

  /// Creates a new instance of a meal plan from a map.
  static DBMealPlan fromMap(Map<String, dynamic> map) {
    return DBMealPlan(map[columnMealPlanID], map[columnLineID], map[columnDate],
        map[columnIsClosed] == 1);
  }

  /// The string to create a table for a meal plan.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealPlanID TEXT NOT NULL,
      $columnLineID TEXT NOT NULL,
      $columnDate TEXT,
      $columnIsClosed BOOLEAN NOT NULL,
      FOREIGN KEY($columnLineID) REFERENCES ${DBLine.tableName}(${DBLine.columnLineID}),
      PRIMARY KEY($columnMealPlanID, $columnDate)
    )
  ''';
  }

  /// Returns if the line is closed.
  bool get isClosed => _isClosed;

  /// Returns the date of the meal plan.
  String get date => _date;

  /// Returns the id of the line.
  String get lineID => _lineID;

  /// Returns the id of the meal plan.
  String get mealPlanID => _mealPlanID;
}
