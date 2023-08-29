import 'package:app/model/database/model/db_canteen.dart';

import 'database_model.dart';

/// This class represents a line of a canteen in the database.
class DBLine implements DatabaseModel {
  final String _lineID;
  final String _canteenID;
  final String _name;
  final int _position;

  /// The name of the table in the database.
  static const String tableName = 'line';

  /// The name of the column for the line id.
  static const String columnLineID = 'lineID';

  /// The name of the column for the canteen id.
  static const String columnCanteenID = 'canteenID';

  /// The name of the column for the name.
  static const String columnName = 'name';

  /// The name of the column for the position.
  static const String columnPosition = 'position';

  /// Creates a new instance of a line of a canteen as it is represented in the database.
  DBLine(this._lineID, this._canteenID, this._name, this._position);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnLineID: _lineID,
      columnCanteenID: _canteenID,
      columnName: _name,
      columnPosition: _position
    };
  }

  /// Creates a new instance of a line of a canteen from a map.
  static DBLine fromMap(Map<String, dynamic> map) {
    return DBLine(map[columnLineID], map[columnCanteenID], map[columnName],
        map[columnPosition]);
  }

  /// The string to create a table for a line of a canteen.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnLineID TEXT PRIMARY KEY,
      $columnCanteenID TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnPosition INTEGER NOT NULL,
      FOREIGN KEY($columnCanteenID) REFERENCES ${DBCanteen.tableName}(${DBCanteen.columnCanteenID})
    )
  ''';
  }

  /// Returns the position of the line.
  int get position => _position;

  /// Returns the name of the line.
  String get name => _name;

  /// Returns the id of the canteen.
  String get canteenID => _canteenID;

  /// Returns the id of the line.
  String get lineID => _lineID;
}
