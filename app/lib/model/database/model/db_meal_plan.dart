import 'package:app/model/database/model/database_model.dart';

import 'db_line.dart';

class DBMealPlan implements DatabaseModel {
  final String _mealPlanID;
  final String _lineID;
  final String _date;
  final bool _isClosed;

  static const String tableName = 'mealPlan';

  static const String columnMealPlanID = 'mealPlanID';
  static const String columnLineID = 'lineID';
  static const String columnDate = 'date';
  static const String columnIsClosed = 'isClosed';

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
  
  static DBMealPlan fromMap(Map<String, dynamic> map) {
    return DBMealPlan(map[columnMealPlanID], map[columnLineID], map[columnDate], map[columnIsClosed]);
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

  bool get isClosed => _isClosed;

  String get date => _date;

  String get lineID => _lineID;

  String get mealPlanID => _mealPlanID;
}